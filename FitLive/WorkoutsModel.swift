//
//  WorkoutsModel.swift
//  FitLive
//
//  Created by Patrick Hanna on 5/31/20.
//  Copyright © 2020 Patrick Hanna. All rights reserved.
//

import UIKit


struct Workout{
    let id: Int
    let name: String
    let exercises: [Exercise]
}

extension Workout{
    struct Exercise{
        let name: String
        let imageName: String
    }
}


extension Workout{
    static func getAll() -> [Workout]{
        
        return [
            Workout(id: 0, name: "Astronaut", exercises: [
                Exercise(name: "Log in Place", imageName: "Jog in Place"),
                Exercise(name: "Left Side Lunges", imageName: "Left Side Lunges"),
                Exercise(name: "Pull Ups", imageName: "Pull Ups"),
                Exercise(name: "Rest", imageName: "Rest")
            ]),
            Workout(id: 1, name: "Balance", exercises: [
                Exercise(name: "Left Flamingo Stand", imageName: "Left Flamingo Stand"),
                Exercise(name: "Right Flamingo Stand", imageName: "Right Flamingo Stand"),
                Exercise(name: "Left One-Leg Clock", imageName: "Left One-Leg Clock"),
                Exercise(name: "Right One-Leg Clock", imageName: "Right One-Leg Clock")
            ]),
            Workout(id: 2, name: "Cardio", exercises: [
                Exercise(name: "Crunches", imageName: "Crunches"),
                Exercise(name: "Jog in Place", imageName: "Jog in Place"),
                Exercise(name: "Jumping Jacks", imageName: "Jumping Jacks"),
                Exercise(name: "Rest", imageName: "Rest")
            ]),
            Workout(id: 3, name: "Flexibility", exercises: [
                Exercise(name: "Butterfly Stretch", imageName: "Butterfly Stretch 1"),
                Exercise(name: "Downward Doggy", imageName: "Downward Doggy"),
                Exercise(name: "Left Back Toe Touch", imageName: "Left Back Toe Touch"),
                Exercise(name: "Right Back Toe Touch", imageName: "Right Back Toe Touch")
            ]),
            Workout(id: 4, name: "Meditative", exercises: [
                Exercise(name: "Butterfly Stretch", imageName: "Butterfly Stretch 1"),
                Exercise(name: "Butterfly Stretch", imageName: "Butterfly Stretch 2"),
                Exercise(name: "Butterfly Stretch", imageName: "Butterfly Stretch 3"),
                Exercise(name: "Rest", imageName: "Rest")
            ]),
            Workout(id: 5, name: "Strength", exercises: [
                Exercise(name: "Bear Crawl Push-Ups", imageName: "Bear Crawl Push-Ups"),
                Exercise(name: "Crunches", imageName: "Crunches"),
                Exercise(name: "Planks", imageName: "Planks"),
                Exercise(name: "Push-Ups", imageName: "Push-Ups")
            ]),
        ]
        
    }
}
