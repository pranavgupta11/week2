pragma circom 2.0.0;

include "../node_modules/circomlib/circuits/poseidon.circom";
include "../node_modules/circomlib/circuits/mux1.circom";

template CheckRoot(n) { // compute the root of a MerkleTree of n Levels 
    signal input leaves[2**n];
    signal output root;

    //[assignment] insert your code here to calculate the Merkle root from 2^n leaves
    signal transaction[2**n+1];
    component digest[2**n+1];
    var x = 2**n-1;
    for(var i=2**n-1;i>0;i--){
        digest[i] = Poseidon(2);   
        if(x>0){
            digest[i].inputs[1] <== leaves[x];
            x--;
            digest[i].inputs[0] <== leaves[x];
            x--;
            transaction[i] <== digest[i].out;
        } 
        else {
            digest[i].inputs[0] <== transaction[2*i];
            digest[i].inputs[1] <== transaction[2*i+1];
            transaction[i] <== digest[i].out;
        }
    }

    root <== transaction[1];

}
}

template MerkleTreeInclusionProof(n) {
    signal input leaf;
    signal input path_elements[n];
    signal input path_index[n]; // path index are 0's and 1's indicating whether the current element is on the left or right
    signal output root; // note that this is an OUTPUT signal
    //[assignment] insert your code here to compute the root from a leaf and elements along the path
    component poseidon[n];
    signal digest[2*n+1];
    var c=0;
    digest[0]<==leaf;
    var j=0;
    component mx1[n];
    component mx2[n];

    for(var i=0;i<n;i++)

{
    poseidon[i]=Poseidon(2);
    mx1[j]=Mux1();
    mx2[j]=Mux1();
    mx1[j].c[0]<==path_elements[i];
    mx1[j].c[1]<==digest[c];
    mx1[j].s<==path_index[i];
    poseidon[i].inputs[0]<==mx1[j].out;
    mx2[j].c[0]<==digest[c];
    mx2[j].c[1]<==path_elements[i];
    mx2[j].s<==path_index[i];
    poseidon[i].inputs[1]<==mx2[j].out;
    j++;
c++;
digest[c]<==poseidon[i].out;
}
    root<==digest[c];
}