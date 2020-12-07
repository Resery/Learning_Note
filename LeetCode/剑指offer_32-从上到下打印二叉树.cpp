/*
从上到下按层打印二叉树，同一层的节点按从左到右的顺序打印，每一层打印到一行。

 

例如:
给定二叉树: [3,9,20,null,null,15,7],

    3
   / \
  9  20
    /  \
   15   7
返回其层次遍历结果：

[
  [3],
  [9,20],
  [15,7]
]
 

提示：

节点总数 <= 1000

来源：力扣（LeetCode）
链接：https://leetcode-cn.com/problems/cong-shang-dao-xia-da-yin-er-cha-shu-ii-lcof
著作权归领扣网络所有。商业转载请联系官方授权，非商业转载请注明出处。


别人的解题思路：
利用 queue + 维护两个变量。我们定义 nextLevel 来记录下一层的元素个数，再定义 remaining 来记录当前层剩余的元素个数。每向一维数组 temp 数组里添加一个当前层的元素，remaining 就 -1，当 remaining 等于 0 时，说明当前层全部添加完毕，那就把 temp 数组添加入最终的二维数组 res 中。

作者：superkakayong
链接：https://leetcode-cn.com/problems/cong-shang-dao-xia-da-yin-er-cha-shu-ii-lcof/solution/zi-jie-ti-ku-jian-32-ii-jian-dan-cong-shang-dao-xi/
来源：力扣（LeetCode）
著作权归作者所有。商业转载请联系作者获得授权，非商业转载请注明出处。
*/

/**
 * Definition for a binary tree node.
 * struct TreeNode {
 *     int val;
 *     TreeNode *left;
 *     TreeNode *right;
 *     TreeNode(int x) : val(x), left(NULL), right(NULL) {}
 * };
 */
class Solution {
public:
    vector<vector<int>> levelOrder(TreeNode* root) {
        if(!root) return {};
        vector<vector<int> >res;
        vector<int> temp;
        queue<TreeNode *> bfs;
        bfs.push(root);
        int nextLevel = 0, remaining = 1;
        while(!bfs.empty())
        {
            TreeNode *curr = bfs.front();
            temp.push_back(curr -> val);
            bfs.pop();
            remaining --; // temp中每添加一个当前层元素，remaining -1
            if(curr -> left)
            {
                bfs.push(curr -> left);
                nextLevel ++; // 下一层的元素个数 +1
            }
            if(curr -> right)
            {
                bfs.push(curr -> right);
                nextLevel ++; // 下一层的元素个数 +1
            }
            if(remaining == 0)
            {
                // 当前层元素全部添加完毕
                res.push_back(temp);
                temp.clear(); // 清空 temp
                remaining = nextLevel; // 当前层剩余元素变成下一层的全部元素
                nextLevel = 0; // 下一层元素清空，用于记录下下层元素
            }
        }
        return res;
    }
};