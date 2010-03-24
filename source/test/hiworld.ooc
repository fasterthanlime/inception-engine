import engine/[Entity, Property]

main: func {
    
    eng := Engine new()
    
    ent := Entity new("Player")
    ent addUpdate(AskName new())
    
    eng add(ent)
    
    engine run()
    
}

AskName: func {
    
}
