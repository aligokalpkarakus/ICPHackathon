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
      birthDate: Text;         // Doğum tarihi
      geoLocation: Text;       // Lokasyon
  };

  public type ElephantPack = { // Fil sürüsü için liste
    packID:Nat32;
    leaderID:?ElephantID;
    elephantsList : Trie.Trie<Nat32, ElephantID>;
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


  private func key(x: ElephantID) : Trie.Key<ElephantID>{ // id
    {hash=x;key=x};
  };

  // Fil oluşturma
  public func addElephant(isHealthy: Bool, parent: ?Nat32, birthDate: Text,geoLocation:Text): async Bool {
    let id = elephant_count;
    elephant_count += 1;

    var newElephant: Elephant = {
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

  // Sürü oluşturma
  public func createPack(geoLoc:Text) : async Bool{
      let id = pack_count;
      pack_count += 1;
      var list : Trie.Trie<Nat32, ElephantID> = Trie.empty();

      var newPack : ElephantPack = {
        packID = id;
        leaderID = null;
        elephantsList=list;
        packGeoLoc = geoLoc;
        };

      packRegistry := Trie.replace(
        packRegistry,
        key(id),
        Nat32.equal,
        ?newPack
      ).0;

      return true;
  };


  // Sürü bilgileri
  public func getPack(id : Nat32): async ?ElephantPack{
    let result = Trie.find(
      packRegistry,
      key(id),
      Nat32.equal
      );

    return result;
  };


  //Sürüye fil ekleme
  public func addElephantToPack(packID : Nat32, elephantID : Nat32) : async Bool {
    // Try to find the pack in the registry
    let result = Trie.find(
        packRegistry,
        key(packID),
        Nat32.equal
    );

    switch (result) {
        case (?elephantPack) { // Found the ElephantPack
            // Update the elephantsList in the pack
            let updatedElephantsList = Trie.replace(
                elephantPack.elephantsList,
                key(elephantID),
                Nat32.equal,
                ?elephantID
            ).0;

            // Create an updated pack with the modified elephantsList
            let updatedPack : ElephantPack = {
                elephantsList = updatedElephantsList;
                leaderID = elephantPack.leaderID;
                packGeoLoc = elephantPack.packGeoLoc;
                packID = packID;
            };

            // Update the packRegistry
            packRegistry := Trie.replace(
                packRegistry,
                key(packID),
                Nat32.equal,
                ?updatedPack
            ).0;

            return true; // Successfully updated the pack
        };
        case (null) { // The pack was not found
            return false; // Operation failed because packID does not exist
        };
    };  
  };

  // Filin sağlık durumunu değiştirme
  public func updateElephantHealth(id: ElephantID, newHealthStatus: Bool): async Bool {
      let result = Trie.find(
          elephantRegistry,
          key(id),
          Nat32.equal
      );

      switch (result) {
          case (?elephant) { // Fil bulundu
              // Yeni sağlık durumu ile filin bilgilerini güncelle
              let updatedElephant : Elephant = {
                  id = elephant.id;
                  isHealthy = newHealthStatus;
                  parent = elephant.parent;
                  birthDate = elephant.birthDate;
                  geoLocation = elephant.geoLocation;
              };

              // Güncellenmiş fil bilgisini elephantRegistry'ye kaydet
              elephantRegistry := Trie.replace(
                  elephantRegistry,
                  key(id),
                  Nat32.equal,
                  ?updatedElephant
              ).0;

              return true; // Sağlık durumu başarıyla güncellendi
          };
          case (null) { // Fil bulunamadı
              return false; // Filin ID'si bulunamadı
          };
      };
  };

  // Sürüye lider atama fonksiyonu
  public func setPackLeader(packID: Nat32, elephantID: ElephantID): async Bool {
      let result = Trie.find(
          packRegistry,
          key(packID),
          Nat32.equal
      );

      switch (result) {
          case (?elephantPack) { // Pack bulundu
              // Lider olarak atanacak filin varlığını kontrol et
              let elephantResult = Trie.find(
                  elephantRegistry,
                  key(elephantID),
                  Nat32.equal
              );

              switch (elephantResult) {
                  case (?elephant) { // Fil bulundu
                      // Yeni lider olarak atanacak file göre paketi güncelle
                      let updatedPack : ElephantPack = {
                          packID = elephantPack.packID;
                          leaderID = ?elephantID;
                          elephantsList = elephantPack.elephantsList;
                          packGeoLoc = elephantPack.packGeoLoc;
                      };

                      // Güncellenmiş pack'i packRegistry'ye kaydet
                      packRegistry := Trie.replace(
                          packRegistry,
                          key(packID),
                          Nat32.equal,
                          ?updatedPack
                      ).0;

                      return true; // Lider başarıyla atandı
                  };
                  case (null) { // Fil bulunamadı
                      return false; // Verilen elephantID geçersiz
                  };
              };
          };
          case (null) { // Pack bulunamadı
              return false; // Verilen packID geçersiz
          };
      };
  };

  // Paketten fil çıkarma fonksiyonu
  public func removeElephantFromPack(packID: Nat32, elephantID: ElephantID): async Bool {
      let result = Trie.find(
          packRegistry,
          key(packID),
          Nat32.equal
      );

      switch (result) {
          case (?elephantPack) { // Pack bulundu
              // Eğer çıkarılacak fil, lider fil ise liderID'yi null yap
              let newLeaderID = if (elephantPack.leaderID == ?elephantID) {
                  null
              } else {
                  elephantPack.leaderID
              };

              // Paketten fili çıkar
              let updatedElephantsList = Trie.remove(
                  elephantPack.elephantsList,
                  key(elephantID),
                  Nat32.equal
              ).0;

              // Güncellenmiş pack'i oluştur
              let updatedPack : ElephantPack = {
                  packID = elephantPack.packID;
                  leaderID = newLeaderID; // Yeni liderID
                  elephantsList = updatedElephantsList;
                  packGeoLoc = elephantPack.packGeoLoc;
              };

              // Güncellenmiş pack'i packRegistry'ye kaydet
              packRegistry := Trie.replace(
                  packRegistry,
                  key(packID),
                  Nat32.equal,
                  ?updatedPack
              ).0;

              return true; // Başarıyla çıkarıldı
          };
          case (null) { // Pack bulunamadı
              return false; // Paket bulunamadı
          };
      };
  };
}
