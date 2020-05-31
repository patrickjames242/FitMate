//
//  WorkoutTimer.swift
//  FitLive
//
//  Created by Patrick Hanna on 5/31/20.
//  Copyright © 2020 Patrick Hanna. All rights reserved.
//

import Foundation



class WorkoutTimer{
    
    struct State{
        let exercise: Workout.Exercise
        let exerciseSecondsRemaining: TimeInterval
        let totalExerciseSeconds: TimeInterval
    }
    
    private var remainingExercises: [Workout.Exercise]
    
    let stateChangedNotification = CustomNotification<State?>()
    
    private(set) var state: State?{
        didSet{
            stateChangedNotification.post(with: state)
        }
    }
    
    private let individualWorkOutTimes: TimeInterval
    
    
    init(workout: Workout, totalWorkoutTimeInSeconds: TimeInterval = 60 * 5){
        guard workout.exercises.count > 0 else {fatalError("workout must have at least one exercise")}
        self.individualWorkOutTimes = (totalWorkoutTimeInSeconds / Double(workout.exercises.count)).rounded()
        self.remainingExercises = workout.exercises
    }
    
    private(set) var isWorkoutStarted = false
    
    private var currentEllapsedExerciseTime = 0
    
    private var timer: Timer?
    
    func startWorkout(){
        guard isWorkoutStarted == false else {return}
        isWorkoutStarted = true
        self.incrementState()
        self.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: {[weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }
            self.currentEllapsedExerciseTime += 1
            self.incrementState()
        })
    }
    
    
    private func incrementState(){
        guard let state = state else {
            if let first = remainingExercises.first{
                self.state = State(exercise: first, exerciseSecondsRemaining: self.individualWorkOutTimes, totalExerciseSeconds: self.individualWorkOutTimes)
                remainingExercises.removeFirst()
            }
            return
        }
        
        let newState: State?
        
        if state.exerciseSecondsRemaining > 1{
            newState = State(exercise: state.exercise, exerciseSecondsRemaining: state.exerciseSecondsRemaining - 1, totalExerciseSeconds: self.individualWorkOutTimes)
        } else if let next = remainingExercises.first{
            newState = State(exercise: next, exerciseSecondsRemaining: self.individualWorkOutTimes, totalExerciseSeconds: self.individualWorkOutTimes)
            remainingExercises.removeFirst()
        } else {
            newState = nil
            self.timer?.invalidate()
        }
        
        self.state = newState
    }
    
    
    
    
}




