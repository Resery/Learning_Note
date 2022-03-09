# libAFL

## 前言

最近在学习 fuzz 和 rust ，碰巧看到了这个项目，用 rust 写的 fuzz ，所以准备研究一下 libAFL 的原理与使用。使用部分主要是根据 libAFL 的作者的另一个名为 Fuzzing101 的项目来学习。原理则是分析一下 libAFL 的源码。

## How to use libAFL

### 环境搭建

环境搭建参考后方链接，此文不再赘述，参考链接：https://epi052.gitlab.io/notes-to-self/blog/2021-11-01-fuzzing-101-with-libafl/#exercise-1-setup 。

### Fuzzing Xpdf

#### libAFL 关键组件介绍

Fuzzing101 相应章节的博客中对 libAFL 的各个组件解释的并不是很好，所以推荐先看一下 libAFL 的文档，看完文档才能对这些关键的组件有一个初步的认识。不过此文也只是对每个组件进行一个简短的介绍，主要目的是让读者能对每个组件有一个初步的认识。

关键组件:
- Observer: 用来获取当前测试用例运行的一些信息。
- Executor: 通过 Executor 可以指定如何启动 target ，比如可以通过 harness function 来启动 target ，也可以直接启动 target ，根据 target 的不同可以选择不同的启动方式。
- Feedback: 用来评判测试用例是否会覆盖新的边，如果会覆盖到新的边则会将其添加到语料库中。
- Input: 用来指定输入的形式，输入可以是最普通的 byte 也可以是以 AST 抽象语法数的形式作为输入。
- Corpus: 用来指定语料的存储位置如硬盘或内存中.
- Mutator: 根据输入类型的不同提供不同类型的变异，比如变异 byte 类型的输入和变异 AST 类型的输入是使用不同的方法的。
- Generator: 针对某一些输入的生成器，用来生成初始的语料。
- Stage: 用来指定变异中的具体的每一步。

#### Writint the fuzzer

##### Components: Corpus + Input

首先创建一个语料库，语料库我们选择将其存储在内存中，存储在内存中的主要目的是减少磁盘访问次数，以提升效率。

```rust
// Create a directory to store the corpus.
let corpus_dirs = vec![PathBuf::from("./corpus")];

// Put the corpus into memory.
let input_corpus = InMemoryCorpus::<BytesInput>::new();
```

然后再创建一个语料库来存储可以触发 crash 的 testcase 。

```rust
// Create a directory to store the corpus that invoked crash.
let timeout_corpus = OnDiskCorpus::new(PathBuf::from("./timeout")).expect("Could not create timeout corpus");
```

##### Component: Observer

Observer 我们选择了 TimeObserver ，TimeObserver 会记录当前 testcase 的运行时间。不过我们同样想观察覆盖率情况，想要观察覆盖率情况则需使用 HitcountsMapObserver ，若想使用 HitcountsMapObserver 我们需要创建一个共享内存，并让 Executor 也使用该共享内存统计覆盖率，由此我们即可获取到覆盖率信息。

```rust
// New a TimeObserver to kepp track of the current testcase's runtime.
let time_observer = TimeObserver::new("time");

// Crate a shared memory that will be used between HitcountsMapObserver and Executor.
const MAP_SIZE: usize = 65536;
-------------8<-------------
let mut shmem = StdShMemProvider::new().unwrap().new_map(MAP_SIZE).unwrap();

// Executor use the environment named "__AFL_SHM_ID" to determine use which shared memory.
shmem.write_to_env("__AFL_SHM_ID").expect("couldn't write shared memory ID");

let mut shmem_map = shmem.map_mut();

// New a HitcountsMapObserver to keep track of the coverage map.
let edges_observer = HitcountsMapObserver::new(ConstMapObserver::<_, MAP_SIZE>::new(
    "shared_mem",
    &mut shmem_map,
));
```

##### Component: Feedback

根据 Observer 返回的结果来判断当前的测试用例是否覆盖了新的边，若覆盖了新边则将其添加到语料库中。Feedback 可能会绑定一个 FeedbackSate ，FeedbackState 代表 Feedback interested testcase 运行时的状态。

针对我们的 fuzzer ，因为我们前面的 Observer 可以统计 testcase 的运行时间以及覆盖率信息，所以我们的 Feedback 也应该通过运行时间和覆盖率信息来决定 testcase 是否为 interesting 。针对覆盖率信息的判断我们选择使用 MapFeedbackState 。

```rust
let feedback_state = MapFeedbackState::with_observer(&edges_observer);
```

MapFeedbackState 和对应的 HitcountsMapObserver 会作为初始化参数传入 MaxMapFeedback 。MaxMapFeedback 会判断 HitcountMapObserver 的覆盖率，如果覆盖率超过了当前存储的 maximum value 就会将输入设置为 interesting 。

创建了 MaxMapFeedback 之后，我们同样也需要创建一个新的 TimeFeedback 来绑定前面创建的 TimeObserver 。但是有一点需要注意，TimeFeedback 本身对确定 testcase 是否为 interesting 没有任何帮助。不过可以通过开发人员自定义的行为利用 TimeFeedback 来确定是否为 interesting 。

现在创建了两个 Feedback 组件，然后我们使用 feedback_or 宏将两个组件合并为 CombineFeedback 。

如果 testcase 处于 interesting 需要手动将 input 放到语料库中。

```rust
let feedback = feedback_or!(
    MaxMapFeedback::new_tracking(&feedback_state, &edges_observer, true, false),
    TimeFeedback::new_with_observer(&time_observer)
);
```

现在已经可以根据覆盖率和运行时间来判断 interesting 了，不过接下来我们会创建一些新的 Feedback 提供不一样的功能。

和上面的 feedback 类似，我们需要创建一个新的 MapFeedbackState ，但是不同的地方在于上面使用 Observer 提供的覆盖率信息，这里我们会单独创建一个 memory map 去提供覆盖率信息。

```rust
const MAPS_SIZE: usize = 65536;
// -------------8<-------------
let objective_state = MapFeedbackState::new("timeout_edges", MAP_SIZE);
```

同样我们也需要将两个 Feedbacks 组合起来，上面是通过 compile 来组合两个 Feedbacks 这里我们仅仅使用 & 来组合两个 Feedbacks 。我们使用 feedback_and_fast 宏。现在面临的问题就是 MaxMapFeedback 和 TimeoutFeedback 我们还没有。

我们的目标是挖到一个无线递归的漏洞。我们 interested 的 testcase 是可以让 target hang 的 testcase 。所以我们就应该有两个评判标准，一是 testcase 可以触发新的代码路径，二是 testcase 运行时间过长（超过开发者设置的 timeout ）。


```rust
let objective = feedback_and_fast!(
    TimeoutFeedback::new(),
    MaxMapFeedback::new(&objective_state, &edges_observer)
);
```

##### Component: State

State 会获取每一个 FeedbackState ，随机数生成器和 corpora 的所有权。

```rust
let mut state = StdState::new(
    StdRand::with_seed(current_nanos()),
    input_corpus,
    timeouts_corpus,
    tuple_list!(feedback_state, objective_state),
);
```

##### Component: Stats

Stats 用来打印 fuzzer 运行的信息。这里我们使用最简单的 Stats ，SimpleStats ，SimpleStats 会将 log 打印在终端上。

```rust
let stats = SimpleStats::new(|s| println!("{}", s));
```

##### Component: EventManager

EventManager 用来处理 fuzzing 过程中阐述的各种时间。比如说找到一个 interesting testcase ，更新 Stats 以及日志记录。这里我们同样使用最简单的 EventManager ，SimpleEventManager 。

```rust
let mut mgr = SimpleEventManager::new(stats);
```

##### Component: Scheduler

Scheduler 用来将已经存入 corpus 的 interesting testcase 重新作为输入喂给 target 。

```rust
let scheduler = IndexesLenTimeMinimizerCorpusScheduler::new(QueueCorpusScheduler::new());
```

##### Component: Fuzzer

Fuzzer 用来组合上面所有的组件成一个新的整体，使用 Fuzzer 就可以统一的进行 Fuzz 。

```rust
let mut fuzzer = StdFuzzer::new(scheduler, feedback, objective);
```

##### Component: Executor

这里我们使用 TimeoutForkserverExecutor 。TimeoutForkserverExecutor 包装了标准的 ForkserverExecutor ，并且在每次运行前都设置了一个 timeout 。这就可以实现与 AFL 类似的机制即使用子进程进行 fuzz 。

创建 Executor 时应指定我们想执行什么。在我们当前的例子中，我们想要运行下面这个目标：

```
./path/to/pdftotext INPUT_FILE
```

我们需要将 target 的路径、输入的路径、以及用到的 Observer 作为 ForkserverExecutor 的初始化参数。

```rust
let fork_server = ForkserverExecutor::new(
    "./xpdf/install/bin/pdftotext".to_string(),
    &[String::from("@@")],
    false,  // use_shmem_testcase
    tuple_list!(edges_observer, time_observer),
).unwrap();
```

然后设置一个超时时长，然后将 fork_server 和 timeout 传给 TimeoutForkserverExeutor 作为其构造函数。

```rust
let timeout = Duration::from_millis(5000);

// ./pdftotext @@
let mut executor = TimeoutForkserverExecutor::new(fork_server, timeout).unwrap();
```

##### Components: Mutator + Stage



## The principle of libAFL

### Basic arch

### Why rust?

### Source code analysis

## 总结

## 参考链接