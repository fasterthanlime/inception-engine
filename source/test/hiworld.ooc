import engine/[Engine, Entity, Property, Update]

main: func {
    
    engine := Engine new()
    
    player := Entity new("Player") .\
    addUpdate(Update new(func -> Bool {
        "username: " print()
        s := String new(128)
        scanf("%s", s)
        
        "Hi there, %s" format(s) println()
        false
    }))
    
    engine run()
    
}
