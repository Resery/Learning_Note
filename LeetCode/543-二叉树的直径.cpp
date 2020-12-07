/*
给定一棵二叉树，你需要计算它的直径长度。一棵二叉树的直径长度是任意两个结点路径长度中的最大值。这条路径可能穿过也可能不穿过根结点。

 

示例 :
给定二叉树

          1
         / \
        2   3
       / \     
      4   5    
返回 3, 它的长度是路径 [4,2,1,3] 或者 [5,2,1,3]。

 

注意：两结点之间的路径长度是以它们之间边的数目表示。

来源：力扣（LeetCode）
链接：https://leetcode-cn.com/problems/diameter-of-binary-tree
著作权归领扣网络所有。商业转载请联系官方授权，非商业转载请注明出处。
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
    

    int depth_func(TreeNode* root,int &max_dep){
        if(!root)
            return 0;
        int left_depth = depth_func(root->left,max_dep);
        int right_depth = depth_func(root->right,max_dep);
        max_dep = max(max_dep,left_depth+right_depth+1);
        return max(left_depth,right_depth) + 1;
    }

    int diameterOfBinaryTree(TreeNode* root) {
        int max_dep=1;
        if(!root)
            return 0;
        depth_func(root,max_dep);
        return max_dep - 1;
    }
};