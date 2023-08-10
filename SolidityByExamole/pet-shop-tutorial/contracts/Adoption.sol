pragma solidity ^0.5.16;
contract Adoption{
    address[16] public adopters;//保留领养者地址

    //领养宠物
    function adopter(uint petId )public returns(uint) {
        require(petId >=0 && petId<=15);

        adopters[petId] = msg.sender;
        return petId;
    }

    function getAdopters()public view returns(address[16] memory) {
            return adopters;
    }
}