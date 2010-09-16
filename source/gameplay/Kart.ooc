use sdl

import engine/[Engine, Entity, Property, Update, EventMapper, Message, Types]
import gfx/[RenderWindow, Cube, Scene, Quad, Line, Camera, Texture]
import gfx/md5/MD5Loader, gfx/r2m/R2MModel

import sdl/[Sdl, Event]

import physics/[PhysicsEngine, Body, Box, Geometry]

import math

CameraMode: enum {
    THIRD_PERSON
    BIRDS_EYE
}

kart_minPt := Float2 new()
kart_maxPt := Float2 new()

Kart: class extends Entity {

    model := MD5Loader load("data/models/tricycle/tricycle.md5mesh")
    bboxModel := Cube new("kart_bbox")
    body := Body new("kart_body")
    geom := Box new("kart_geom")

    minmaxLine1 := Line new("minmax")
    minmaxLine2 := Line new("minmax")
    minmaxLine3 := Line new("minmax")
    minmaxLine4 := Line new("minmax")

    maxSpeed := 230.0
    speed: Float {
        get {
            body vel length() / maxSpeed
        }
    }
    
    orientationAxis := Line new("kart_direction")
    velocityAxis := Line new("kart_velocity")
    axisLength := 25.0
    
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

        body pos set(0, 0, 0.01)
    }

    update: func {
        super()

        aFactor := 0.6
        bFactor := 1.0 - aFactor

        currentSpeed := dist(Float3 new(), body vel)

        turnSpeed := 1.3
        actualTurnSpeed := turnSpeed * (1.0 - ((maxSpeed - currentSpeed) / maxSpeed * 0.3))
        
        if(turnLeft) {
            alpha += actualTurnSpeed
        } else if(turnRight) {
            alpha -= actualTurnSpeed
        }

        alphaRad := alpha * PI / 180.0
            
        if(brake || accelerate) {
            speed := currentSpeed

            if(brake) {
                if(speed > 3.0) speed *= 0.9
                else if(speed > maxSpeed * -0.5) speed -= 10.0
            } else if(accelerate) {
                if(speed < maxSpeed) speed += 10.0
            }

            body vel set(
                body vel x * 0.87 + (cos(alphaRad) * speed) * 0.13,
                body vel y * 0.87 + (sin(alphaRad) * speed) * 0.13,
                0
            )
        } else {
            body vel scale(0.98)
        }
        
        velDir := Float2 new(body vel x, body vel y)
        velDir normalize()
        
        unitDir := Float2 new(cos(alphaRad), sin(alphaRad))
        dot := velDir dot(unitDir)

        if(-1.0 < dot && dot < 1.0) {
            velNorm := body vel length()
            // less adherence if we brake
            body vel scale(brake ? dot : (dot * 0.5 + 0.5))

            epsilon := brake ? 0.9999 : 0.9
            body vel set(
                (body vel x * epsilon) + (unitDir x * velNorm * (1.0 - epsilon)),
                (body vel y * epsilon) + (unitDir y * velNorm * (1.0 - epsilon)),
                0
            )
        }
        
        orientationAxis get("end", Float3) set(
            body pos x + (unitDir x * axisLength),
            body pos y + (unitDir y * axisLength),
            0.1
        )

        velocityAxis get("end", Float3) set(
            body pos x + (body vel x / maxSpeed * axisLength),
            body pos y + (body vel y / maxSpeed * axisLength),
            0.1
        )
        
        if(camMode == CameraMode THIRD_PERSON) {
            cameraDistance := 20
            cameraHeight := 15

            pos := cam get("position", Float3)
            pos set(
                pos x * aFactor + (body pos x - cos(alphaRad) * cameraDistance) * bFactor,
                pos y * aFactor + (body pos y - sin(alphaRad) * cameraDistance) * bFactor,
                cameraHeight
            )
    
            cam theta = (cam theta * 0.9) + (alpha * 0.1)
            
            cam phi = -20
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

        // now handle collisions
        level := engine getEntity("level") as R2MModel
        reaction := Float3 new()
        
        for(trackbound in level geometries) {
            if(geom collide(trackbound, reaction)) {
                /*
                ("Got a collision! geom pos = " + geom get("position", Float3) toString() +
                    ", geom rot = " + geom get("eulerAngles", Float3) toString() +
                    ", trackbound pos = " + trackbound get("position", Float3) toString() +
                    " reaction = " + reaction toString()) println()
                */
                body pos += reaction

                velDir = Float2 new(body vel x, body vel y)
                velDir normalize()

                reac2D := Float2 new(reaction x, reaction y)
                reac2D normalize()
                dot = velDir dot(reac2D)

                body vel -= (reaction * dot)
                body vel scale(body vel length() > (maxSpeed * 0.5) ? 0.7 : 0.97)

                break
            }
        }

        minX := body pos x + (kart_minPt x * cos(alphaRad))
        maxX := body pos x + (kart_maxPt x * cos(alphaRad))
        minY := body pos y + (kart_minPt y * sin(alphaRad))
        maxY := body pos y + (kart_maxPt y * sin(alphaRad))

        epsilon := 0.1

        minmaxLine1 get("begin", Float3) set(minX, minY, epsilon)
        minmaxLine1 get("end",   Float3) set(maxX, minY, epsilon)

        minmaxLine2 get("begin", Float3) set(maxX, minY, epsilon)
        minmaxLine2 get("end",   Float3) set(maxX, maxY, epsilon)
        
        minmaxLine3 get("begin", Float3) set(maxX, maxY, epsilon)
        minmaxLine3 get("end",   Float3) set(minX, maxY, epsilon)

        minmaxLine4 get("begin", Float3) set(minX, maxY, epsilon)
        minmaxLine4 get("end",   Float3) set(minX, minY, epsilon)
    }
    
    onAdd: func {
        engine scene addModel(model)
        
        cam = engine getEntity("default_cam") as Camera
        cam set("sensitivity", 0)
        cam set("speed", 0)
        
        physx := engine getEntity("physx") as PhysicsEngine
        physx add(body, model)
        //model show = false

        // add and bind the bounding box
        engine scene addModel(bboxModel)
        bboxModel set("scale", Float3 new(4.0, 4.0, 6.0))
        //bboxModel wire = true
        bboxModel show = false
        body pos bind(bboxModel pos)
        body rot bind(bboxModel rot)

        // bind the geom
        body pos bind(geom get("position", Float3))
        body rot bind(geom get("eulerAngles", Float3))
        geom get("scale", Float3) set(bboxModel get("scale", Float3))

        // add minmax lines
        engine scene addModel(minmaxLine1)
        engine scene addModel(minmaxLine2)
        engine scene addModel(minmaxLine3)
        engine scene addModel(minmaxLine4)

        // add various axis
        engine scene addModel(orientationAxis)
        body pos bind(orientationAxis get("begin", Float3))
        orientationAxis set("color", Float3 new(0, 1, 0))
        
        engine scene addModel(velocityAxis)
        body pos bind(velocityAxis get("begin", Float3))
        orientationAxis set("color", Float3 new(1, 0, 1))
    }

}

