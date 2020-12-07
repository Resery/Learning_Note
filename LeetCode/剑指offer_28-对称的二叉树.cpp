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

    bool recur(TreeNode* left,TreeNode* right){
        if(!left && !right) return true;
        if(!left || !right || left->val != right->val) return false;
        return recur(left->left,right->right) && recur(left->right,right->left);
    }

    bool isSymmetric(TreeNode* root) {
        return !root ? true : recur(root->left,root->right);
    }
};