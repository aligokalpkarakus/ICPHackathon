import Nat32 "mo:base/Nat32";
import Trie "mo:base/Trie";
import Option "mo:base/Option";
import List "mo:base/List";
import Text "mo:base/Text";
import Result "mo:base/Result";

actor {

  public type SuperHero = { // data type
    name: Text;
    superpowers: List.List<Text>;
  };

  // media datalar private tutulur
  public type SuperHeroId = Nat32;
  private stable var next : SuperHeroId = 0; // SuperHeroId tipinde next değişkeni. Değiştirilebilir olması için var olmalı.
  private stable var superheroes : Trie.Trie<SuperHeroId,SuperHero> = Trie.empty(); // SuperHeroId (32 bitlik Nat32) ve SuperHero ekleniyor

  public func createHero(newHero: SuperHero) : async Nat32{
    
    let id = next;
    next += 1;

    superheroes := Trie.replace(
      superheroes,
      key(id),
      Nat32.equal,
      ?newHero // buradaki ? trie yapısı hata olmasına izin vermeyen yapı, yani null değer gelirse ? hata vermeksizin kayıt yapmayı sağlayacak.
    ).0;
    
    return id;
  };

  public func getHero(id: SuperHeroId) : async ?SuperHero{
    let result = Trie.find( // değişikliği önlemek amacıyla let tipini kullanarak hero'nun bilgilerini result'a atıyoruz
      superheroes,
      key(id),
      Nat32.equal
    ); 
    result
  };

  public func updateHero(id: SuperHeroId, newHero: SuperHero) : async Bool {
    let result = Trie.find( // değişikliği önlemek amacıyla let tipini kullanarak hero'nun bilgilerini result'a atıyoruz
      superheroes,
      key(id),
      Nat32.equal
    ); 

    let exists = Option.isSome(result);

    if(exists){
      superheroes := Trie.replace(
        superheroes,
        key(id),
        Nat32.equal,
        ?newHero // buradaki ? trie yapısı hata olmasına izin vermeyen yapı, yani null değer gelirse ? hata vermeksizin kayıt yapmayı sağlayacak.
      ).0;
    };
    exists
  };

  public func delete(id: SuperHeroId) : async Bool {
    let result = Trie.find( // değişikliği önlemek amacıyla let tipini kullanarak hero'nun bilgilerini result'a atıyoruz
      superheroes,
      key(id),
      Nat32.equal
    ); 

    let exists = Option.isSome(result);

    if(exists){
      superheroes := Trie.replace(
        superheroes,
        key(id),
        Nat32.equal,
        null // O id'de bulunan hero'yu null yapar
      ).0;
    };
    exists
  };

  private func key(x: SuperHeroId): Trie.Key<SuperHeroId>{ // id şifreleniyor. key-value ilişkisi yaratılıyor.
    {hash = x; key = x};
  };






















};
