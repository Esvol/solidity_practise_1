// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

// Merkle tree

contract Lesson_8 {
    //    ROOT
    //  H1-2, H3-4
    // H1, H2, H3, H4
    // TX1, TX2, TX3, TX4
    
    bytes32[] public hashes;
    string[8] public transactions = [
        "TX1: Sherlock -> John",
        "TX2: John -> Sherlock",
        "TX3: John -> Mary",
        "TX4: Mary -> Sherlock",
        "TX5: Pitty -> Skarlet",
        "TX6: Skarlet -> Dorry",
        "TX7: Viktor -> Dorry",
        "TX8: Dorry -> Pitty"
    ];

    constructor() {
        for(uint i=0; i < transactions.length; i++){
            hashes.push(makeHash(transactions[i]));
        }

        uint count = transactions.length;
        uint offset = 0;

        while(count > 0){
            for (uint i = 0; i < count - 1; i+=2){
                hashes.push(
                    keccak256(
                        abi.encodePacked(
                            hashes[offset + i], hashes[offset + i + 1]
                        )
                    )
                );
            }
            offset += count;
            count = count / 2;
        }
    }
 
    function verify(string memory transaction) public view returns(bool){
        bytes32 root = hashes[hashes.length - 1];
        bytes32 hash = makeHash(transaction);
        uint indexTakenHash;
        uint pairAmount = (((hashes.length-1)/2)+1)/2;
        uint usedPair = 0;
        uint totalPair = 0;
        
        for (uint i=0; i<hashes.length - 1; i++){
            if(hashes[i] == hash){
                indexTakenHash = i;
            }
        }

        for(uint j=pairAmount; j>0; j/=2){
            if(indexTakenHash%2 == 1 && indexTakenHash != hashes.length - 1){
                hash = keccak256(abi.encodePacked(hashes[indexTakenHash - 1], hash));
            }
            else if(indexTakenHash%2 == 0 && indexTakenHash != hashes.length - 1){
                hash = keccak256(abi.encodePacked(hash, hashes[indexTakenHash + 1]));
            }
            
            if (indexTakenHash == hashes.length - 1 || indexTakenHash + 1 == hashes.length - 1 || indexTakenHash + 2 == hashes.length - 1){
                j = 0;
            }

            for(uint i=totalPair*2; i<=indexTakenHash; i+=2){
                usedPair++;
            }

            totalPair += j;

            if(usedPair % 2 == 0){
                usedPair = totalPair + (usedPair / 2);
                indexTakenHash = ((usedPair - 1) * 2) + 1;
                usedPair = 0;
            }
            else{
                usedPair = totalPair + ((usedPair+1) / 2);
                indexTakenHash = (usedPair - 1) * 2;
                usedPair = 0;
            }
            
        }

        return hash == root;
    }

    function encode(string memory input) public pure returns(bytes memory) {
        return abi.encodePacked(input);
    }

    function makeHash(string memory input) public pure returns(bytes32){
        return keccak256(
            encode(input)
        );
    }
}
