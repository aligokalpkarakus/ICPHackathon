import Debug "mo:base/Debug";
import List "mo:base/List";
import Trie "mo:base/Trie";
import Principal "mo:base/Principal";
import Nat32 "mo:base/Nat32"


actor ElephantTracker {


    public type ElephantID = Nat32;

    // Fil bilgileri için veri yapısı
    public type Elephant = {
        id: ElephantID;           // Benzersiz kimlik
        isHealthy: Bool;        // Sağlık durumu
        parent: ?Nat32;          // Parent ID (opsiyonel, yoksa null)
        birthDate: Text;
        geoLocation: Text;
    };

    public type ElephantPack = {
      packID:Nat32;
      leaderID:ElephantID;
      elephantsList : List.List<ElephantID>;
      packGeoLoc : Text;
    };


  
  
    stable var elephant_count: Nat32 = 0;
    stable var pack_count :Nat32 = 0;

    // Fil kayıtları için bir sözlük
    stable var elephantRegistry: Trie.Trie<Nat32, Elephant> = Trie.empty();
    stable var packRegistry: Trie.Trie<Nat32, ElephantPack> = Trie.empty();

    public shared (message) func whoami() : async Principal {
      return message.caller;
    };


    private func key(x: ElephantID) : Trie.Key<ElephantID>{
      {hash=x;key=x};
    };

    public func addElephant(isHealthy: Bool, parent: ?Nat32, birthDate: Text,geoLocation:Text): async Bool {
      let id = elephant_count;
      elephant_count += 1;

      let newElephant: Elephant = {
        id;           // Benzersiz kimlik
        isHealthy;        // Sağlık durumu
        parent;          // Parent ID (opsiyonel, yoksa null)
        birthDate;
        geoLocation;
        };

        elephantRegistry := Trie.replace(elephantRegistry,
        key(id),
        Nat32.equal,
        ?newElephant
        ).0;
        return true;
    };


    // Bir filin bilgilerini getirme
    public func getElephant(id: ElephantID): async ?Elephant {
       let result = Trie.find(
        elephantRegistry,
        key(id),
        Nat32.equal
       );

       return result;
    };

    public func createPack(leaderID:ElephantID,geoLoc:Text) : async Bool{
        let id = pack_count;
        pack_count += 1;
        var list = List.List<ElephantID>;
        let newPack : ElephantPack= {
          id;
          leaderID;
          ;
          geoLoc;
          };

        

        packRegistry := Trie.replace(
          packRegistry,
          key(id),
          Nat32.equal,
          ?newPack
        ).0;

        return true;
    };


    public func getPack(packID : Nat32): async ElephantPack{
      let result = Trie.find(
        packRegistry,
        key(packID),
        Nat32.equal
       );

      return result;
    }

}
