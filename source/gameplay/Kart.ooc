use sdl

import engine/[Engine, Entity, Property, Update, EventMapper, Message, Types]
import gfx/[RenderWindow, Cube, Scene, Quad, Line, Camera, Texture]
import gfx/md5/MD5Loader

import sdl/[Sdl, Event]

import physics/[PhysicsEngine, Body]

import math

CameraMode: enum {
    THIRD_PERSON
    BIRDS_EYE
}

Kart: class extends Entity {

    model := MD5Loader load("data/models/tricycle/tricycle.md5mesh")
    bboxModel := Cube new("kart_bbox")
    body := Body new("kart_body")
    
    cam: Camera
    camMode := CameraMode THIRD_PERSON

    alpha := 0.0

    turnLeft := false
    turnRight := false
    accelerate := false
    brake := false

    init: func {
        super("kart")

        listen(KeyboardMsg, |_m|
            m := _m as KeyboardMsg

            if(m type != SDL_KEYUP && m type != SDL_KEYDOWN) return

            val := (m type == SDL_KEYDOWN)
            match(m key) {
                case SDLK_UP    => accelerate = val
                case SDLK_DOWN  => brake      = val
                case SDLK_LEFT  => turnLeft   = val
                case SDLK_RIGHT => turnRight  = val
                case SDLK_c     =>
                    if(val) {
                        camMode = (camMode == CameraMode BIRDS_EYE) ? CameraMode THIRD_PERSON : CameraMode BIRDS_EYE
                    }
            }
        )
    }

    update: func {
        super()

        aFactor := 0.92
        bFactor := 1.0 - aFactor

        maxSpeed := 200.0
        currentSpeed := dist(Float3 new(), body vel)

        turnSpeed := 1.5
        actualTurnSpeed := turnSpeed * (1.0 - ((maxSpeed - currentSpeed) / maxSpeed))
        
        if(turnLeft) {
            alpha += actualTurnSpeed
        } else if(turnRight) {
            alpha -= actualTurnSpeed
        }
            
        if(brake || accelerate) {
            speed := currentSpeed

            if(brake) {
                if(speed > 0.0) speed *= 0.5
            } else if(accelerate) {
                if(speed < maxSpeed) speed += 5.0
            }

            body vel set(
                cos(alpha * PI / 180.0) * speed,
                sin(alpha * PI / 180.0) * speed,
                0
            )
        }
        "current / max = %.2f / %.2f" printfln(currentSpeed, maxSpeed)
        
        if(camMode == CameraMode THIRD_PERSON) {
            cameraDistance := 30
            cameraHeight := 25

            pos := cam get("position", Float3)
            pos set(
                pos x * aFactor + (body pos x - cos(alpha * PI / 180.0) * cameraDistance) * bFactor,
                pos y * aFactor + (body pos y - sin(alpha * PI / 180.0) * cameraDistance) * bFactor,
                cameraHeight
            )
    
            cam theta = (cam theta * 0.9) + (alpha * 0.1)
            
            cam phi = -25
            cam vectorsFromAngles()
        } else if(camMode == CameraMode BIRDS_EYE) {
            cameraHeight := 120
            cam get("position", Float3) set(
                body pos x,
                body pos y,
                cameraHeight
            )

            cam theta = alpha
            cam phi = -90
            cam vectorsFromAngles()
        }

        if(alpha < 0) {
            alpha += 360.0
            cam theta += 360.0
        }
        if(alpha > 360.0) {
            alpha -= 360.0
            cam theta -= 360.0
        }
        
        body rot set(0.0, 0.0, alpha - 90)
    }
    
    onAdd: func {
        engine scene addModel(model)
        
        cam = engine getEntity("default_cam") as Camera
        cam set("sensitivity", 0)
        cam set("speed", 0)
        
        physx := engine getEntity("physx") as PhysicsEngine
        physx add(body, model)

        // add and bind the bounding box
        engine scene addModel(bboxModel)
        bboxModel set("side", 4.0)
        bboxModel wire = true
        body pos bind(bboxModel pos)
        body rot bind(bboxModel rot)
    }

}

