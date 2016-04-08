protocol Component {
    static var name: String { get } // not necessary (see comments below)
}

extension Component {
    // can be overridden with `let` by conforming types
    static var name: String { return String(self.dynamicType) }
}

protocol Entity {
    var components: [String: Component] { get set }

    static func with(_: Component...) -> Self

    init()
    func component<T: Component>(_: T.Type) -> T?
    mutating func add<T: Component>(component: T)
    mutating func remove<T: Component>(_: T.Type) -> T?
}

extension Entity {

    /// Returns a new entity with components
    ///
    static func with(components: Component...) -> Self {
        var _components = [String: Component]()

        for component in components {
            _components[component.dynamicType.name] = component
        }

        var entity = self.init()
        entity.components = _components
        return entity
    }

    /// Returns a component of a specific type
    ///
    func component<T: Component>(_: T.Type) -> T? {
        return self.components[T.name/* String(T) */] as? T
    }

    /// Adds a component of a specific type
    ///
    mutating func add<T: Component>(component: T) {
        self.components[T.name] = component
    }

    /// Removes a component of a specific type, also returns it
    ///
    mutating func remove<T: Component>(_: T.Type) -> T? {
        let component = self.components[T.name]
        self.components[T.name] = nil
        return component as? T
    }
}

// Libraries
struct Character: Entity {
    var components = [String: Component]()
}

struct Health: Component {
    var percent = 100.0
    var dead: Bool { return percent <= 0 }
}

struct Attack: Component {
    var range = 0
    var damage = 0
}

struct Movement: Component {
    var start = (0, 0)
    var end = (0, 0)
}

// Usage
let health = Health()
let attack = Attack()

var character = Character.with(health, attack)

character.component(Health)?.percent
character.components.count

let movement = Movement()
character.add(movement)
character.components.count

character.component(Movement)?.start

character.remove(Attack)
character.component(Attack)
character.components.count
