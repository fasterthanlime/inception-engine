import structs/[ArrayList, HashMap, Stack]
import Property, Update, Message, Engine

Entity: class {
    
    engine: Engine
    
    name: String
    id: Int
    
    props := HashMap<String, Property> new()
    updates := ArrayList<Update> new()
    receivers := ArrayList<Receiver> new()
    queue := ArrayList<Message> new()
    
    idSeed := static 0
    
    init: func ~withName(=name) {
        This idSeed += 1
        id = This idSeed
    }
    
    addUpdate: func (update: Update) { updates add(update) }
    
    getName: func -> String { name }
    
    update: func {
        
        if(!updates empty?()) {
            //printf("[%d] %s got %d updates to run\n", id, name, updates size())
            iter := updates iterator()
            while(iter hasNext?()) {
                up := iter next()
                //printf("[%d] %s running update %s\n", id, name, up class name)
                if(!up run(this)) {
                    iter remove()
                }
            }
        }
        
        
        while(!queue empty?()) {
            msg := queue get(0)
            queue removeAt(0)
            for(r in receivers) {
                if(r messageType inheritsFrom?(msg class)) {
                    r call(msg)
                }
            }
        }
    }
    
    listen: func (type: MessageClass, call: Func (Message)) {
        receivers add(Receiver new(type, call))
    }
    
    send: func (target: Entity, msg: Message) {
        //printf("Sending message of type %s from %s to %s\n", msg class name, name, target name)
        msg sender = this
        msg target = target
        target queue add(msg)
    }
    
    sendAll: func (msg: Message) {
        for(entity in engine entities) {
            has := true
            for(receiver in entity receivers) {
                if(receiver messageType inheritsFrom?(msg class)) {
                    has = true
                    break
                }
            }
            if(has) {
                send(entity, msg clone())
            }
        }
    }
    
    annihilate: func {
        
    }
    
    // Generic properties convenience functions
    
    set: func <T> (name: String, value: T) {
        prop := props get(name)
        if(prop) {
            if(!prop instanceOf?(GenericProperty)) {
                Exception new(This, "Attempting to set value of %s as if it was a generic property, but it's a %s" format(name, prop class name)) throw()
            }
            prop as GenericProperty set(value)
        } else {
            prop = GenericProperty new(name, value)
            props put(name, prop)
        }
    }
    
    get: func <T> (name: String, T: Class) -> T {
        prop := props get(name)
        if(!prop) return null
        if(!prop instanceOf?(GenericProperty)) {
            Exception new(This, "Attempting to get (%s, %s), but the property isn't generic but a %s" format(name, T name, prop class name)) throw()
        }
        gp := prop as GenericProperty<T>
        if(!gp T inheritsFrom?(T)) {
            Exception new(This, "Attempting to get (%s, %s), but the property has incompatible type %s" format(name, T name, gp T name)) throw()
        }
        return gp get()
    }
    
    /**
     * Called after it has been added to the Engine
     */
    onAdd: func {}
    
    /**
     * Called before being removed from the Engine
     */
    onRemove: func {}
}

Receiver: class {

    messageType: MessageClass
    call: Func (Message)
    
    init: func (=messageType, =call) {}
    
}
