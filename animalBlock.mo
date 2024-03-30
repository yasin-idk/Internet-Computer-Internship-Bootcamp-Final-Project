import Trie "mo:base/Trie";
import Nat32 "mo:base/Nat32";
import Array "mo:base/Array";
import Iter "mo:base/Iter";

actor AnimalBlock {
  type AnimalId = Nat32; 
  type Animal = {                  
    name : Text;                
    species : Text;         
    sex : Text;      
    city : Text;                
    vaccinationStatus : Bool;   
    delisted : Bool;            
    delistReason : Text;        
  };

  //created types AnimalId and Animal

  private func key(x: AnimalId): Trie.Key<AnimalId>{
    { hash = x; key = x};
  };

  //hashing

  private stable var nextId : AnimalId = 0;
  private stable var animals : Trie.Trie<AnimalId, Animal> = Trie.empty();

  //created nextId for unique id giving and created an empty Trie.Trie to store animals

  public func addAnimal(animal: Animal): async AnimalId {
    let animalId = nextId;
    nextId += 1;
    animals := Trie.replace(animals, key(animalId), Nat32.equal, ?animal).0;
    animalId
  };

  //Input all animal values to add to the Trie with Trie.replace
  
  public func updateVaccinationStatus(animalId: AnimalId, newVaccinationStatus: Bool): async () {
  let oldAnimal = Trie.find(animals, key(animalId), Nat32.equal);
  switch (oldAnimal) {
    case (?oldAnimal) {
      let updatedAnimal = {
        name = oldAnimal.name;
        species = oldAnimal.species;
        sex = oldAnimal.sex;
        city = oldAnimal.city;
        vaccinationStatus = newVaccinationStatus;
        delisted = oldAnimal.delisted;
        delistReason = oldAnimal.delistReason;
      };
      animals := Trie.replace(animals, key(animalId), Nat32.equal, ?updatedAnimal).0;
    };
    case null {
      return;
      };
    };
  };

  //Finds animal with AnimalId, and then creates a new animal with new vaccination status to replace the old one.

  public func getAnimals() : async [Animal] {
    let arrayOfAnimals = Array.map<(AnimalId, Animal), Animal>(Iter.toArray(Trie.iter(animals)), func ((_, Animal)) { Animal });
    arrayOfAnimals;
  };

  //gets all animals, regardless of being delisted

  public func getAnimalsByCity(city: Text) : async [Animal] {
    let filteredAnimals = Trie.filter<AnimalId, Animal>(
      animals,
      func(animalId, animal) : Bool {
        (animal.city == city and animal.delisted == false)
      }
    );
    let arrayOfAnimals = Array.map<(AnimalId, Animal), Animal>(Iter.toArray(Trie.iter(filteredAnimals)), func ((_, Animal)) { Animal }); 
    arrayOfAnimals;
  };

  //filters all animals with the same city and brings them out

  public func getAnimalsBySpecies(species: Text) : async [Animal] {
    let filteredAnimals = Trie.filter<AnimalId, Animal>(
      animals,
      func(animalId, animal) : Bool {
        (animal.species == species   and animal.delisted == false)
      }
    );
    let arrayOfAnimals = Array.map<(AnimalId, Animal), Animal>(Iter.toArray(Trie.iter(filteredAnimals)), func ((_, Animal)) { Animal }); 
    arrayOfAnimals;
  };

  //filters all animals with the same species and brings them out

  public func getUnvaccinated() : async [Animal] {
    let filteredAnimals = Trie.filter<AnimalId, Animal>(
      animals,
      func(animalId, animal) : Bool {
        (animal.vaccinationStatus == false and animal.delisted == false)
      }
    );
    let arrayOfAnimals = Array.map<(AnimalId, Animal), Animal>(Iter.toArray(Trie.iter(filteredAnimals)), func ((_, Animal)) { Animal });
    arrayOfAnimals;
  };

  //brings unvaccinated animals

  public func getDelisted() : async [Animal] {
    let filteredAnimals = Trie.filter<AnimalId, Animal>(
      animals,
      func(animalId, animal) : Bool {
        animal.delisted == false
      }
    );
    let arrayOfAnimals = Array.map<(AnimalId, Animal), Animal>(Iter.toArray(Trie.iter(filteredAnimals)), func ((_, Animal)) { Animal }); 
    arrayOfAnimals;
  };  

  //calls delisted animals

  public func delistAnimal(animalId: AnimalId, newDelistReason: Text): async () {
    let animalToDelist = Trie.find(animals, key(animalId), Nat32.equal);
    switch (animalToDelist) {
      case (?animalToDelist) {
        let updatedAnimal = {
          name = animalToDelist.name;
          species = animalToDelist.species;
          sex = animalToDelist.sex;
          city = animalToDelist.city;
          vaccinationStatus = animalToDelist.vaccinationStatus;
          delisted = true;
          delistReason = newDelistReason;
        };
        animals := Trie.replace(animals, key(animalId), Nat32.equal, ?updatedAnimal).0;    
      };
      case null {
        return ;
      };
    };
  };

  //finds animal with animalId and then creates a new animal with delisted = true and new delisted information, and then replaces the animal.
};