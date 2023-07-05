// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;
// Uncomment this line to use console.log
// import "hardhat/console.sol";

contract BracketGenerator {
    struct Match {
        uint256 teama;
        uint256 teamb;
        uint256 winner;
    }
    struct Team {
        uint256 id;
        string name;
    }
    struct Bracket {
        string name;
        Team[] participants;
        mapping(uint256=>Match)matchups;
        uint256 initial;
        uint256 preskipped;
        uint256 winner;
        uint256 visible;
    }
    mapping(address => mapping(string => Bracket)) internal db;
    mapping(address => string[]) internal tournaments;

   function getTournamentWinner (string memory name, address owner) public view returns (string memory) {
      return db[owner][name].participants[db[owner][name].winner-1].name;
   }
   function getTournamentParticipants(string memory name,address owner) public view returns(Team[] memory) {
    return db[owner][name].participants;
   }

   function getTournamentMatchups(string memory name, address owner) public view returns(Match[] memory) {
      Match[] memory matches = new Match[](db[owner][name].visible);
      for(uint i=0;i<db[owner][name].visible;i++)
      {
         Match storage member = db[owner][name].matchups[i];
         matches[i]=member;
      }
      return matches;
   }
   function getTournaments (address owner) public view returns (string[] memory) {
      return tournaments[owner];
   }

   function getMatch(uint256 id, address owner, string memory tname) public view returns (Match memory) {
      return db[owner][tname].matchups[id];
   }
   
    function createTournament(string memory name, string[] memory teams)
        public
    {
      Bracket storage newBracket = db[msg.sender][name];
      uint256 i=0;
      uint256 preskipped;
       for (i = 2; i < teams.length; i *= 2) {}
        newBracket.initial = i / 2;
      
      preskipped = i - teams.length;
      newBracket.name = name;
      newBracket.visible=newBracket.initial+preskipped;

      for(uint j = 0; j < teams.length; j++) {
         newBracket.participants.push(Team(j + 1, teams[j]));
         
         if(j<preskipped)
         {
            newBracket.matchups[j].teama=i+1;
            newBracket.matchups[j].teamb=0;
            newBracket.matchups[j].winner=i+1;

            if(newBracket.matchups[(j/2)+newBracket.initial].teama==0)
               newBracket.matchups[(j/2)+newBracket.initial].teama=j;
            else
               newBracket.matchups[(j/2)+newBracket.initial].teamb=j;
         }
         else {
            if(newBracket.matchups[((j-preskipped)/2)+preskipped].teama==0)
               newBracket.matchups[((j-preskipped)/2)+preskipped].teama=j;
            else
               newBracket.matchups[((j-preskipped)/2)+preskipped].teamb=j;
         }

      }
      tournaments[msg.sender].push(name);
    }

    function matchResult(
        string calldata tName,
        uint256 matchid,
        uint256 winner
    ) public {
        require(db[msg.sender][tName].initial * 2 - 1 > matchid);
        require(db[msg.sender][tName].matchups[matchid].winner == 0);
        require(
            winner == db[msg.sender][tName].matchups[matchid].teama ||
                winner == db[msg.sender][tName].matchups[matchid].teamb
        );
        db[msg.sender][tName].matchups[matchid].winner = winner;
        if (matchid != db[msg.sender][tName].initial * 2 - 2) {
            uint256 k = 0;
            uint256 i = matchid;
            uint256 j = db[msg.sender][tName].initial;
            for (; i >= j; ) {
                k = k + j;
                i = i - j;
                j = j / 2;
            }
            uint256 nextId = i / 2 + k;
            if (db[msg.sender][tName].matchups[nextId].teama == 0) {
               db[msg.sender][tName].visible++;
                db[msg.sender][tName].matchups[nextId].teama = winner;
            } else {
                db[msg.sender][tName].matchups[nextId].teamb = winner;
            }
        } else {
            db[msg.sender][tName].winner = winner;
        }
        db[msg.sender][tName].visible++;
    }
}
