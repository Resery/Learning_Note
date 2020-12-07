/*
给你二叉树的根节点 root ，返回它节点值的 前序 遍历。


示例 1：

输入：root = [1,null,2,3]
输出：[1,2,3]

示例 2：

输入：root = []
输出：[]

示例 3：

输入：root = [1]
输出：[1]
示例 4：

来源：力扣（LeetCode）
链接：https://leetcode-cn.com/problems/binary-tree-preorder-traversal
著作权归领扣网络所有。商业转载请联系官方授权，非商业转载请注明出处。
*/
/**
 * Definition for a binary tree node.
 * struct TreeNode {
 *     int val;
 *     TreeNode *left;
 *     TreeNode *right;
 *     TreeNode() : val(0), left(nullptr), right(nullptr) {}
 *     TreeNode(int x) : val(x), left(nullptr), right(nullptr) {}
 *     TreeNode(int x, TreeNode *left, TreeNode *right) : val(x), left(left), right(right) {}
 * };
 */
class Solution {
public:

    void go(TreeNode* root,vector<int> &res){
        if(!root){
            return;
        }
        res.push_back(root->val);
        go(root->left,res);
        go(root->right,res);
    }

    vector<int> preorderTraversal(TreeNode* root) {
        vector<int> ret;
        go(root,ret);
        return ret;
    }
};