import Result "mo:base/Result";
import Text "mo:base/Text";
import Debug "mo:base/Debug";
import Nat "mo:base/Nat";
import Map "mo:map/Map";
import {phash; nhash } "mo:map/Map";
import Vector "mo:vector";

actor {
    stable var autoIndex = 0;
    let userIdMap = Map.new<Principal, Nat>();
    let userProfileMap = Map.new<Nat, Text>();   
    let userResultMap = Map.new<Nat, Vector.Vector<Text>>();   

    public query ({ caller }) func getUserProfile() : async Result.Result<{ id : Nat; name : Text }, Text> {

        //Find user by his caller 
        let userId = switch (Map.get(userIdMap, phash, caller)) {
            case (?idFound) idFound; 
            case (_) return #err("User not found");
        };

        //Find with the userId the text 
        let name = switch (Map.get(userProfileMap, nhash, userId)) {
            case (?idFound) idFound;
            case (_) return #err("User name not found");    
        };
        
        return #ok({ id = userId; name = name });
    };

    public shared ({ caller }) func setUserProfile(name : Text) : async Result.Result<{ id : Nat; name : Text }, Text> {
        
        //check if user ID exist
        switch(Map.get(userIdMap, phash, caller)) { 
            case(?_found) { };
            case(_) {   
            //set user id
            Map.set(userIdMap, phash, caller, autoIndex);
            autoIndex += 1;
           };
        };



        //set user id
       let idFound = switch(Map.get(userIdMap, phash, caller)){
            case(?found) found;
            case(_) {return #err("user not found")};
       };

        //set user profil
        Map.set(userProfileMap, nhash, idFound , name);
        

        return #ok({ id = idFound ; name = name });
    };

    public shared ({ caller }) func addUserResult(result : Text) : async Result.Result<{ id : Nat; results : [Text] }, Text> {
        
        //Find de userId
      let userId = switch (Map.get(userIdMap, phash, caller)) {
            case (?idFound) idFound; 
            case (_) return #err("User not found");
        };

        //Check if user already have a text
        let newText = switch( Map.get(userResultMap, nhash, userId)){
            case (?found) found;
            case (_) Vector.new<Text>();
        };
        

        Vector.add(newText, result);
        Map.set(userResultMap, nhash, userId, newText);

        return #ok({ id = userId ; results = Vector.toArray(newText) });
    };

    public query ({ caller }) func getUserResults() : async Result.Result<{ id : Nat; results : [Text] }, Text> {

        let userId = switch (Map.get(userIdMap, phash, caller)) {
            case (?idFound) idFound; 
            case (_) return #err("User not found");
        };

        let userResult =  switch (Map.get(userResultMap, nhash, userId)) {
            case (?idFound) idFound; 
            case (_) return #err("Result not found");
        };

        return #ok({ id = userId; results =Vector.toArray(userResult)});
    };
};
