// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;
// Uncomment this line to use console.log
// import "hardhat/console.sol";


contract BracketGenerator {

   struct Team {
      uint256 id;
      string name;
   }
   struct Match {
      uint256 id;
      uint256 teama;
      uint256 teamb;
      uint256 winner;
   }
   struct Bracket {

      address creator;
      Match[] matchups;
      string name;
      Team[] participants;
      uint256 initial;
      uint256 winner;
   }


   function shuffle(string[] memory arr) internal view returns(string[] memory) {
    for (uint256 i = 0; i < arr.length; i++) {
        uint256 n = i + uint256(keccak256(abi.encodePacked(block.timestamp))) % (arr.length - i);
        string memory temp = arr[n];
        arr[n] = arr[i];
        arr[i] = temp;
    }
    return arr;
}
   mapping (address=>string[])tournaments;
   mapping(string=>Bracket) internal db;
   function viewTournament (string memory name) public view returns (Bracket memory){
      return db[name];
   }

   function getTournamentWinner (string memory name) public view returns (string memory) {
      return db[name].participants[db[name].winner-1].name;
   }
   function viewTournamentName (string memory name) public view returns (string memory) {
      return db[name].name;
   }
   function getTournamentParticipants(string memory name) public view returns(Team[] memory) {
    return db[name].participants;
   }

   function getTournamentMatchups(string memory name) public view returns(Match[] memory) {
      return db[name].matchups;
   }

   function getTournaments (address owner) public view returns (string[] memory) {
      return tournaments[owner];
   }
   
   function  createTournament(string memory name, string[] memory teams) public {
      
      uint i=0;
      uint preskipped=0;
      teams=shuffle(teams);
      while(i<teams.length)
      {
        db[name].participants.push(Team(i+1,teams[i]));
         i++;
      }
     i = 2;
     
     while(i<teams.length)
     i=i*2;
     db[name].initial=i/2;
     preskipped=i-teams.length;
     db[name].name=name;
     
    uint256 j;
    for(j=0;j<i-1;j++)
    {
      db[name].matchups.push(Match(j,0,0,0));
    }
      for( j=0; j<i/2;j++){
         if(j<preskipped)
         {
            db[name].matchups[j]=Match(j,j+1,0,j+1);
            if(db[name].matchups[j/2+i/2].teama==0)
            db[name].matchups[j/2+i/2].teama=j+1;
            else
            db[name].matchups[j/2+i/2].teamb=j+1;
         }
         else
            db[name].matchups[j]=(Match(j,(j*2)+1-preskipped,(j*2)+2-preskipped,0));
      }
      tournaments[msg.sender].push(name);
      db[name].creator=msg.sender;
   }

   function matchResult(string calldata tName, uint256 matchid, uint256 winner) public {
      require(db[tName].creator==msg.sender);
      require((db[tName].initial*2-1)>matchid);
      require(db[tName].matchups[matchid].winner==0);
      require(db[tName].matchups[matchid].teama!=0 && db[tName].matchups[matchid].teamb!=0);
      require(db[tName].matchups[matchid].teama==winner|| db[tName].matchups[matchid].teamb==winner);
      db[tName].matchups[matchid].winner=winner;
      if(matchid==(db[tName].initial*2)-2){
         db[tName].winner=winner;
         return;
      }
      
      uint256 k = 0;
      uint256 i = matchid;
      uint256 j=db[tName].initial;
      while(i>=j)
      {
         k=k+j;
         i=i-j;
         j=j/2;
      }
      k=k+j;
      uint256 nextId =i/2+k;  
      if(db[tName].matchups[nextId].teama==0)
         db[tName].matchups[nextId].teama=winner;
      else 
         db[tName].matchups[nextId].teamb=winner;
   }   
}