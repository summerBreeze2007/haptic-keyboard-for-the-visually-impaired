import CoreHaptics

struct HapticManager {
    
    static func playHaptics(engine: CHHapticEngine?, events: [CHHapticEvent]) {
        do {
            let pattern = try CHHapticPattern(events: events, parameters: [])
            let player = try engine?.makePlayer(with: pattern)
            try player?.start(atTime: 0)
        } catch {
            print("Failed to play haptic: \(error.localizedDescription)")
        }
    }
    
    /* 복합 피드백 구성 요소(곡선) */
    
    // decay + attack
    static func doHaptics_AttackDecay(
        engine: CHHapticEngine?,
        attackTime: Double = 0.1,
        sustainTime: Double = 0.2,
        decayTime: Double = 0.2,
        peakIntensity: Float = 1.0,
        endIntensity: Float = 0.0,
        baseSharpness: Float = 0.5
    ) {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        let totalDuration = attackTime + sustainTime + decayTime

        let event = CHHapticEvent(
            eventType: .hapticContinuous,
            parameters: [
                CHHapticEventParameter(parameterID: .hapticIntensity, value: peakIntensity),
                CHHapticEventParameter(parameterID: .hapticSharpness, value: baseSharpness)
            ],
            relativeTime: 0,
            duration: totalDuration
        )

        let intensityCurve = CHHapticParameterCurve(
            parameterID: .hapticIntensityControl,
            controlPoints: [
                .init(relativeTime: 0, value: 0.0),
                .init(relativeTime: attackTime, value: peakIntensity),
                .init(relativeTime: attackTime + sustainTime, value: peakIntensity),
                .init(relativeTime: totalDuration, value: endIntensity)
            ],
            relativeTime: 0
        )

        do {
            let pattern = try CHHapticPattern(events: [event], parameterCurves: [intensityCurve])
            let player = try engine?.makePlayer(with: pattern)
            try player?.start(atTime: 0)
        } catch {
            print("Haptic error: \(error)")
        }
    }
    
    // attack
    static func doHaptics_Attack(
        engine: CHHapticEngine?,
        attackTime: Double = 0.1,
        sustainTime: Double = 0.2,
        peakIntensity: Float = 1.0,
        baseSharpness: Float = 0.5,
        startTime: Double = 0.0
    ) {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        let totalDuration = attackTime + sustainTime

        let event = CHHapticEvent(
            eventType: .hapticContinuous,
            parameters: [
                CHHapticEventParameter(parameterID: .hapticIntensity, value: peakIntensity),
                CHHapticEventParameter(parameterID: .hapticSharpness, value: baseSharpness)
            ],
            relativeTime: 0,
            duration: totalDuration
        )

        let intensityCurve = CHHapticParameterCurve(
            parameterID: .hapticIntensityControl,
            controlPoints: [
                .init(relativeTime: startTime, value: 0.0),
                .init(relativeTime: startTime + attackTime, value: peakIntensity),
                .init(relativeTime: startTime + attackTime + sustainTime, value: peakIntensity),
            ],
            relativeTime: 0
        )
        

        do {
            let pattern = try CHHapticPattern(events: [event], parameterCurves: [intensityCurve])
            let player = try engine?.makePlayer(with: pattern)
            try player?.start(atTime: 0)
        } catch {
            print("Haptic error: \(error)")
        }
    }
    
    // decay
    static func doHaptics_Decay(
        engine: CHHapticEngine?,
        sustainTime: Double = 0.2,
        decayTime: Double = 0.2,
        peakIntensity: Float = 1.0,
        endIntensity: Float = 0.0,
        baseSharpness: Float = 0.5,
        startTime: Double = 0.0
    ) {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        let totalDuration = sustainTime + decayTime

        let event = CHHapticEvent(
            eventType: .hapticContinuous,
            parameters: [
                CHHapticEventParameter(parameterID: .hapticIntensity, value: peakIntensity),
                CHHapticEventParameter(parameterID: .hapticSharpness, value: baseSharpness)
            ],
            relativeTime: 0,
            duration: totalDuration
        )

        let intensityCurve = CHHapticParameterCurve(
            parameterID: .hapticIntensityControl,
            controlPoints: [
                .init(relativeTime: startTime + sustainTime, value: peakIntensity),
                .init(relativeTime: startTime + totalDuration, value: endIntensity)
            ],
            relativeTime: 0
        )

        do {
            let pattern = try CHHapticPattern(events: [event], parameterCurves: [intensityCurve])
            let player = try engine?.makePlayer(with: pattern)
            try player?.start(atTime: 0)
        } catch {
            print("Haptic error: \(error)")
        }
    }
    
    // 피드백 조합 로직
    static func makeAttackBlock(
            attackTime: Double,
            sustainTime: Double,
            peakIntensity: Float,
            baseSharpness: Float,
            startTime: Double
        ) -> (CHHapticEvent, CHHapticParameterCurve) {
            let totalDuration = attackTime + sustainTime
            let event = CHHapticEvent(
                eventType: .hapticContinuous,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: peakIntensity),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: baseSharpness)
                ],
                relativeTime: startTime,
                duration: totalDuration
            )
            let curve = CHHapticParameterCurve(
                parameterID: .hapticIntensityControl,
                controlPoints: [
                    .init(relativeTime: startTime, value: 0.0),
                    .init(relativeTime: startTime + attackTime, value: peakIntensity),
                    .init(relativeTime: startTime + attackTime + sustainTime, value: peakIntensity)
                ],
                relativeTime: 0
            )
            return (event, curve)
        }
    
    
    static func doHaptics_straight(engine: CHHapticEngine?, intense: Float = 0.5, sharp: Float = 0.3) -> (CHHapticEvent) {
        
        let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: intense)
        let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: sharp)
        
        let eventLong = CHHapticEvent(eventType: .hapticContinuous, parameters: [intensity, sharpness], relativeTime: 0, duration: 0.5)
        
        return (eventLong)
    }
    
    static func doHaptics_discrete(engine: CHHapticEngine?, intense: Float = 0.5, sharp: Float = 0.3) -> (CHHapticEvent) {
        
        let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: intense)
        let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: sharp)
        
        let eventLong = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: 0, duration: 0.1)
        
        return (eventLong)
    }

    // Returns decay event and curve
    static func makeDecayBlock(
        sustainTime: Double,
        decayTime: Double,
        peakIntensity: Float,
        endIntensity: Float,
        baseSharpness: Float,
        startTime: Double
    ) -> (CHHapticEvent, CHHapticParameterCurve) {
        let totalDuration = sustainTime + decayTime
        let event = CHHapticEvent(
            eventType: .hapticContinuous,
            parameters: [
                CHHapticEventParameter(parameterID: .hapticIntensity, value: peakIntensity),
                CHHapticEventParameter(parameterID: .hapticSharpness, value: baseSharpness)
            ],
            relativeTime: startTime,
            duration: totalDuration
        )
        let curve = CHHapticParameterCurve(
            parameterID: .hapticIntensityControl,
            controlPoints: [
                .init(relativeTime: startTime + sustainTime, value: peakIntensity),
                .init(relativeTime: startTime + totalDuration, value: endIntensity)
            ],
            relativeTime: 0
        )
        return (event, curve)
    }

    // 조합 피드백 함수
    static func playCustomHaptic(
        engine: CHHapticEngine?,
        blocks: [(CHHapticEvent, CHHapticParameterCurve)]
    ) {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        let events = blocks.map { $0.0 }
        let curves = blocks.map { $0.1 }
        do {
            let pattern = try CHHapticPattern(events: events, parameterCurves: curves)
            let player = try engine?.makePlayer(with: pattern)
            try player?.start(atTime: 0)
        } catch {
            print("Haptic error: \(error)")
        }
    }
    
    static func doHaptics_test_Q(engine: CHHapticEngine?) {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }

        let attack = HapticManager.makeAttackBlock(attackTime: 0.3, sustainTime: 0.1, peakIntensity: 0.8, baseSharpness: 0.3, startTime: 0.0)
        let long = HapticManager.doHaptics_straight(engine: engine, intense: 0.5, sharp: 0.3)
        let short = HapticManager.doHaptics_discrete(engine: engine, intense: 0.5, sharp: 0.5)
        
        HapticManager.playCustomHaptic(engine: engine, blocks: [attack])
         
         DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { // 이 함수를 통해 두 신호를 순차적으로 연결합니다. 다른 신호를 추가할 때도 이 형식을 따르시면 됩니다.
             HapticManager.playCustomHaptic(engine: engine, blocks: [attack])
         }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { // 이 함수를 통해 두 신호를 순차적으로 연결합니다. 다른 신호를 추가할 때도 이 형식을 따르시면 됩니다.
            HapticManager.playHaptics(engine: engine, events: [short])
        }
        
    }
    
    static func doHaptics_test_W(engine: CHHapticEngine?) {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }

        let decay = HapticManager.makeDecayBlock(sustainTime: 0.1, decayTime: 0.3, peakIntensity: 0.8, endIntensity: 0.3, baseSharpness: 0.3, startTime: 0.0)
        let long = HapticManager.doHaptics_straight(engine: engine, intense: 0.5, sharp: 0.3)
        let short = HapticManager.doHaptics_discrete(engine: engine, intense: 0.5, sharp: 0.5)
        
        HapticManager.playCustomHaptic(engine: engine, blocks: [decay])
         
         DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { // 이 함수를 통해 두 신호를 순차적으로 연결합니다. 다른 신호를 추가할 때도 이 형식을 따르시면 됩니다.
             HapticManager.playHaptics(engine: engine, events: [short])
         }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { // 이 함수를 통해 두 신호를 순차적으로 연결합니다. 다른 신호를 추가할 때도 이 형식을 따르시면 됩니다.
            HapticManager.playCustomHaptic(engine: engine, blocks: [decay])
        }
        
    }
    
    
    static func doHaptics_test_A(engine: CHHapticEngine?) {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }

        let long = HapticManager.doHaptics_straight(engine: engine, intense: 0.5, sharp: 0.3)
        let short = HapticManager.doHaptics_discrete(engine: engine, intense: 0.5, sharp: 0.5)
        
        HapticManager.playHaptics(engine: engine, events: [short])
         
         DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { // 이 함수를 통해 두 신호를 순차적으로 연결합니다. 다른 신호를 추가할 때도 이 형식을 따르시면 됩니다.
             HapticManager.playHaptics(engine: engine, events: [long])
         }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { // 이 함수를 통해 두 신호를 순차적으로 연결합니다. 다른 신호를 추가할 때도 이 형식을 따르시면 됩니다.
            HapticManager.playHaptics(engine: engine, events: [short])
        }
        
    }
    
    static func doHaptics_test_S(engine: CHHapticEngine?) {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }

        let decay = HapticManager.makeDecayBlock(sustainTime: 0.1, decayTime: 0.3, peakIntensity: 0.8, endIntensity: 0.3, baseSharpness: 0.3, startTime: 0.0)
        let attack = HapticManager.makeAttackBlock(attackTime: 0.3, sustainTime: 0.1, peakIntensity: 0.8, baseSharpness: 0.3, startTime: 0.0)
        
        HapticManager.playCustomHaptic(engine: engine, blocks: [attack])

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
             HapticManager.playCustomHaptic(engine: engine, blocks: [decay])
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            HapticManager.playCustomHaptic(engine: engine, blocks: [decay])
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { // 이 함수를 통해 두 신호를 순차적으로 연결합니다. 다른 신호를 추가할 때도 이 형식을 따르시면 됩니다.
            HapticManager.playCustomHaptic(engine: engine, blocks: [attack])
        }
        
    }
    
    static func doHaptics_test_Z(engine: CHHapticEngine?) {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }

        let long = HapticManager.doHaptics_straight(engine: engine, intense: 0.5, sharp: 0.3)
        let short = HapticManager.doHaptics_discrete(engine: engine, intense: 0.5, sharp: 0.8)
        
        HapticManager.playHaptics(engine: engine, events: [long])
         
         DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { // 이 함수를 통해 두 신호를 순차적으로 연결합니다. 다른 신호를 추가할 때도 이 형식을 따르시면 됩니다.
             HapticManager.playHaptics(engine: engine, events: [short])
         }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { // 이 함수를 통해 두 신호를 순차적으로 연결합니다. 다른 신호를 추가할 때도 이 형식을 따르시면 됩니다.
            HapticManager.playHaptics(engine: engine, events: [long])
        }
        
    }
    
    static func doHaptics_test_X(engine: CHHapticEngine?) {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }

        let long = HapticManager.doHaptics_straight(engine: engine, intense: 0.5, sharp: 0.8)
        
        HapticManager.playHaptics(engine: engine, events: [long])
         
         DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { // 이 함수를 통해 두 신호를 순차적으로 연결합니다. 다른 신호를 추가할 때도 이 형식을 따르시면 됩니다.
             HapticManager.playHaptics(engine: engine, events: [long])
         }
        
    }
    
    static func doHaptics_test_E(engine: CHHapticEngine?) {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }

        let long = HapticManager.doHaptics_straight(engine: engine, intense: 0.5, sharp: 0.3)
        let short = HapticManager.doHaptics_discrete(engine: engine, intense: 0.5, sharp: 0.5)
        
        HapticManager.playHaptics(engine: engine, events: [long])
         
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { // 이 함수를 통해 두 신호를 순차적으로 연결합니다. 다른 신호를 추가할 때도 이 형식을 따르시면 됩니다.
             HapticManager.playHaptics(engine: engine, events: [short])
         }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { // 이 함수를 통해 두 신호를 순차적으로 연결합니다. 다른 신호를 추가할 때도 이 형식을 따르시면 됩니다.
            HapticManager.playHaptics(engine: engine, events: [short])
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { // 이 함수를 통해 두 신호를 순차적으로 연결합니다. 다른 신호를 추가할 때도 이 형식을 따르시면 됩니다.
            HapticManager.playHaptics(engine: engine, events: [short])
        }
        
    }
    
    static func doHaptics_test_R(engine: CHHapticEngine?) {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }

        let attack = HapticManager.makeAttackBlock(attackTime: 0.3, sustainTime: 0.1, peakIntensity: 0.8, baseSharpness: 0.3, startTime: 0.0)
        let long = HapticManager.doHaptics_straight(engine: engine, intense: 0.5, sharp: 0.3)
        let short = HapticManager.doHaptics_discrete(engine: engine, intense: 0.5, sharp: 0.5)
        
        
        HapticManager.playHaptics(engine: engine, events: [long])
         
         DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { // 이 함수를 통해 두 신호를 순차적으로 연결합니다. 다른 신호를 추가할 때도 이 형식을 따르시면 됩니다.
             HapticManager.playCustomHaptic(engine: engine, blocks: [attack])
         }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { // 이 함수를 통해 두 신호를 순차적으로 연결합니다. 다른 신호를 추가할 때도 이 형식을 따르시면 됩니다.
            HapticManager.playHaptics(engine: engine, events: [short])
        }
        
    }
    
    static func doHaptics_test_D(engine: CHHapticEngine?) {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }

        let decay = HapticManager.makeDecayBlock(sustainTime: 0.1, decayTime: 0.3, peakIntensity: 0.8, endIntensity: 0.3, baseSharpness: 0.3, startTime: 0.0)
        let long = HapticManager.doHaptics_straight(engine: engine, intense: 0.5, sharp: 0.3)
        
        HapticManager.playHaptics(engine: engine, events: [long])

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
             HapticManager.playCustomHaptic(engine: engine, blocks: [decay])
        }
    }
    
    static func doHaptics_test_F(engine: CHHapticEngine?) {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }

        let long = HapticManager.doHaptics_straight(engine: engine, intense: 0.5, sharp: 0.3)
        let short = HapticManager.doHaptics_discrete(engine: engine, intense: 0.5, sharp: 0.5)
        
        HapticManager.playHaptics(engine: engine, events: [short])
         
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { // 이 함수를 통해 두 신호를 순차적으로 연결합니다. 다른 신호를 추가할 때도 이 형식을 따르시면 됩니다.
             HapticManager.playHaptics(engine: engine, events: [short])
         }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { // 이 함수를 통해 두 신호를 순차적으로 연결합니다. 다른 신호를 추가할 때도 이 형식을 따르시면 됩니다.
            HapticManager.playHaptics(engine: engine, events: [long])
        }
    }
    
    static func doHaptics_test_C(engine: CHHapticEngine?) {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }

        let decay = HapticManager.makeDecayBlock(sustainTime: 0.3, decayTime: 0.1, peakIntensity: 0.8, endIntensity: 0.3, baseSharpness: 0.3, startTime: 0.0)
        let attack = HapticManager.makeAttackBlock(attackTime: 0.1, sustainTime: 0.3, peakIntensity: 0.8, baseSharpness: 0.3, startTime: 0.0)
        
        HapticManager.playCustomHaptic(engine: engine, blocks: [attack])

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
             HapticManager.playCustomHaptic(engine: engine, blocks: [decay])
        }
    }
    
    static func doHaptics_test_V(engine: CHHapticEngine?) {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }

        let long = HapticManager.doHaptics_straight(engine: engine, intense: 0.5, sharp: 0.3)
        let attack = HapticManager.makeAttackBlock(attackTime: 0.1, sustainTime: 0.3, peakIntensity: 0.8, baseSharpness: 0.8, startTime: 0.0)
        
        HapticManager.playHaptics(engine: engine, events: [long])

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            HapticManager.playCustomHaptic(engine: engine, blocks: [attack])
        }
    }
    
    static func doHaptics_test_T(engine: CHHapticEngine?) {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }

        let short = HapticManager.doHaptics_discrete(engine: engine, intense: 0.5, sharp: 0.8)
        let decay = HapticManager.makeDecayBlock(sustainTime: 0.1, decayTime: 0.3, peakIntensity: 0.8, endIntensity: 0.3, baseSharpness: 0.3, startTime: 0.0)
        
        HapticManager.playHaptics(engine: engine, events: [short])

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
             HapticManager.playCustomHaptic(engine: engine, blocks: [decay])
        }
    }
    
    static func doHaptics_test_G(engine: CHHapticEngine?) {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }

        let decay = HapticManager.makeDecayBlock(sustainTime: 0.1, decayTime: 0.3, peakIntensity: 0.8, endIntensity: 0.3, baseSharpness: 0.3, startTime: 0.0)
        
        HapticManager.playCustomHaptic(engine: engine, blocks: [decay])

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
             HapticManager.playCustomHaptic(engine: engine, blocks: [decay])
        }
    }
        
    static func doHaptics_ContinousIntensity(engine: CHHapticEngine?) {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        let intensity = CHHapticEvent(
            eventType: .hapticContinuous,
            parameters: [
                CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.3)
            ],
            relativeTime: 0,
            duration: 1.0)
        
        let intensityCurve = CHHapticParameterCurve(
            parameterID: .hapticIntensityControl,
            controlPoints: [
                CHHapticParameterCurve.ControlPoint(relativeTime: 0, value: 0.3),
                CHHapticParameterCurve.ControlPoint(relativeTime: 0.3, value: 0.8),
                CHHapticParameterCurve.ControlPoint(relativeTime: 0.7, value: 0.3)
            ],
            relativeTime: 0
        )
        do{
            let pattern = try CHHapticPattern(events: [intensity], parameterCurves: [intensityCurve])
            let player = try engine?.makePlayer(with: pattern)
            try player?.start(atTime: 0)
        } catch {
            print("Haptic error: \(error)")
        }
    }

    static func doHaptics_ContinousSharpness(engine: CHHapticEngine?) {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        let sharpness = CHHapticEvent(
            eventType: .hapticContinuous,
            parameters: [
                CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.3),
                //CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.3)
                CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.3)
            ],
            relativeTime: 0,
            duration: 1.0)
        
        
        let sharpnessCurve = CHHapticParameterCurve(
            parameterID: .hapticSharpnessControl,
            controlPoints: [
                CHHapticParameterCurve.ControlPoint(relativeTime: 0.0, value: 0.0),
                CHHapticParameterCurve.ControlPoint(relativeTime: 0.15, value: 0.5),
                CHHapticParameterCurve.ControlPoint(relativeTime: 0.5, value: 1.5),
                CHHapticParameterCurve.ControlPoint(relativeTime: 0.65, value: 0.5),
                CHHapticParameterCurve.ControlPoint(relativeTime: 1.0, value: 0.0)
            ],
            relativeTime: 0
        )
        
        let intensityCurve = CHHapticParameterCurve(
                parameterID: .hapticIntensityControl,
                controlPoints: [
                    .init(relativeTime: 0.0, value: 0.3),
                    .init(relativeTime: 0.15, value: 0.8),
                    .init(relativeTime: 0.5, value: 1.5),
                    .init(relativeTime: 0.65, value: 0.8),
                    .init(relativeTime: 1.0, value: 0.3)
                ],
                relativeTime: 0
            )

        do{
            let pattern = try CHHapticPattern(events: [sharpness], parameterCurves: [sharpnessCurve, intensityCurve])
            let player = try engine?.makePlayer(with: pattern)
            try player?.start(atTime: 0)
        } catch {
            print("Haptic error: \(error)")
        }
    }
    
    static func doHaptics_ContinousBoth_upward(engine: CHHapticEngine?) {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        let sharpness = CHHapticEvent(
            eventType: .hapticContinuous,
            parameters: [
                CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.3),
                //CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.3)
                CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.0)
            ],
            relativeTime: 0,
            duration: 1.0)
        
        let sharpnessCurve = CHHapticParameterCurve(
            parameterID: .hapticSharpnessControl,
            controlPoints: [
                CHHapticParameterCurve.ControlPoint(relativeTime: 0.0, value: 0.3),
                CHHapticParameterCurve.ControlPoint(relativeTime: 0.5, value: 0.5),
                CHHapticParameterCurve.ControlPoint(relativeTime: 1.0, value: 1.0),
                
            ],
            relativeTime: 0
        )
        
        let intensityCurve = CHHapticParameterCurve(
                parameterID: .hapticIntensityControl,
                controlPoints: [
                    .init(relativeTime: 0.0, value: 0.0),
                    .init(relativeTime: 0.5, value: 0.3),
                    .init(relativeTime: 1.0, value: 1.0)
                ],
                relativeTime: 0
            )

        do{
            let pattern = try CHHapticPattern(events: [sharpness], parameterCurves: [sharpnessCurve, intensityCurve])
            let player = try engine?.makePlayer(with: pattern)
            try player?.start(atTime: 0)
        } catch {
            print("Haptic error: \(error)")
        }
    }
    
    
    static func doHaptics_ContinousSharpness_reversed(engine: CHHapticEngine?) {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        let sharpness = CHHapticEvent(
            eventType: .hapticContinuous,
            parameters: [
                //CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.2)
                CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.3)
            ],
            relativeTime: 0,
            duration: 1.0)
        
        // decay, attack, realtiveTime
        
        let sharpnessCurve = CHHapticParameterCurve(
            parameterID: .hapticSharpnessControl,
            controlPoints: [
                CHHapticParameterCurve.ControlPoint(relativeTime: 0.0, value: 1.0),
                CHHapticParameterCurve.ControlPoint(relativeTime: 0.25, value: 0.5),
                CHHapticParameterCurve.ControlPoint(relativeTime: 0.5, value: 0.0),
                CHHapticParameterCurve.ControlPoint(relativeTime: 0.75, value: 0.5),
                CHHapticParameterCurve.ControlPoint(relativeTime: 1.0, value: 1.0)
            ],
            relativeTime: 0
        )
        do{
            let pattern = try CHHapticPattern(events: [sharpness], parameterCurves: [sharpnessCurve])
            let player = try engine?.makePlayer(with: pattern)
            try player?.start(atTime: 0)
        } catch {
            print("Haptic error: \(error)")
        }
    }
    
    static func doHaptics_ContinousSharpness_S_reversed(engine: CHHapticEngine?) {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        let sharpness = CHHapticEvent(
            eventType: .hapticContinuous,
            parameters: [
                //CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.3)
                CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.3)
            ],
            relativeTime: 0,
            duration: 1.0)
        
        let sharpnessCurve = CHHapticParameterCurve(
            parameterID: .hapticSharpnessControl,
            controlPoints: [
                CHHapticParameterCurve.ControlPoint(relativeTime: 0, value: 0.0),
                CHHapticParameterCurve.ControlPoint(relativeTime: 0.25, value: 1.0),
                CHHapticParameterCurve.ControlPoint(relativeTime: 0.5, value: 0.5),
                CHHapticParameterCurve.ControlPoint(relativeTime: 0.75, value: 0.0),
                CHHapticParameterCurve.ControlPoint(relativeTime: 1.0, value: 0.5)
            ],
            relativeTime: 0
        )
        do{
            let pattern = try CHHapticPattern(events: [sharpness], parameterCurves: [sharpnessCurve])
            let player = try engine?.makePlayer(with: pattern)
            try player?.start(atTime: 0)
        } catch {
            print("Haptic error: \(error)")
        }
    }
    
    static func doHaptics_ContinousSharpness_S(engine: CHHapticEngine?) {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        let sharpness = CHHapticEvent(
            eventType: .hapticContinuous,
            parameters: [
                //CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.2)
                CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.3)
            ],
            relativeTime: 0,
            duration: 1.0)
        
        let sharpnessCurve = CHHapticParameterCurve(
            parameterID: .hapticSharpnessControl,
            controlPoints: [
                CHHapticParameterCurve.ControlPoint(relativeTime: 0, value: 0.5), // 0.4
                CHHapticParameterCurve.ControlPoint(relativeTime: 0.25, value: 0.0), // 0.0
                CHHapticParameterCurve.ControlPoint(relativeTime: 0.5, value: 0.5), // 0.4
                CHHapticParameterCurve.ControlPoint(relativeTime: 0.75, value: 1.0), // 0.8
                CHHapticParameterCurve.ControlPoint(relativeTime: 1.0, value: 0.5) // 0.4
            ],
            relativeTime: 0
        )
        do{
            let pattern = try CHHapticPattern(events: [sharpness], parameterCurves: [sharpnessCurve])
            let player = try engine?.makePlayer(with: pattern)
            try player?.start(atTime: 0)
        } catch {
            print("Haptic error: \(error)")
        }
    }
    
    /* 복합 피드백 구성 요소(점,선) */
    
    static func doHaptics_Line(engine: CHHapticEngine?) {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        
        let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.5)
        let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.5)
        
        let event = CHHapticEvent(eventType: .hapticContinuous, parameters: [intensity, sharpness], relativeTime: 1.0, duration: 0.5)
        
        playHaptics(engine: engine, events: [event])
    }
    
    static func doHaptics_dot(engine: CHHapticEngine?) {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        
        let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.8)
        let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.8)
        
        let event = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: 1.0, duration: 0.1)
        
        playHaptics(engine: engine, events: [event])
    }
    
    
    /* 복합 피드백 */
    
    static func doHaptics_A(engine: CHHapticEngine?) {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        doHaptics_AttackDecay(engine: engine, attackTime: 0.1, sustainTime: 0.1, decayTime: 0.3, peakIntensity: 1.0, endIntensity: 0.5, baseSharpness: 0.5)
    }
    
    static func doHaptics_Q(engine: CHHapticEngine?) {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        doHaptics_ContinousSharpness_S_reversed(engine: engine)
        //doHaptics_Line(engine: engine)
        doHaptics_dot(engine: engine)
    }
    
    static func doHaptics_W(engine: CHHapticEngine?) {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        doHaptics_ContinousSharpness_reversed(engine: engine)
        doHaptics_ContinousSharpness_reversed(engine: engine)
    }
    
    static func doHaptics_S(engine: CHHapticEngine?) {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        doHaptics_ContinousSharpness_S(engine: engine)
        
    }
    
    
    /* 손가락 떼어냈을 때 발생하는 입력 피드백 */
    
    static func doHaptics_onEnded(engine: CHHapticEngine?) {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0)
        let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.8)
        let event = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: 0, duration: 0.2)
        playHaptics(engine: engine, events: [event])
    }
    
    /* 버튼에 임의로 할당된 햅틱 피드백 */
    
    static func doHaptics_00(engine: CHHapticEngine?) {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        
        let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.5)
        let intensity2 = CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0)
        let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 1.0)
        let sharpness2 = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.5)
        
        let event = CHHapticEvent(eventType: .hapticContinuous, parameters: [intensity, sharpness], relativeTime: 0.2, duration: 0.1)
        let eventShort = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: 0.3, duration: 0.1)
        let event2 = CHHapticEvent(eventType: .hapticContinuous, parameters: [intensity2, sharpness2], relativeTime: 0.1, duration: 0.2)
        
        playHaptics(engine: engine, events: [event])
        playHaptics(engine: engine, events: [eventShort])
        playHaptics(engine: engine, events: [event2])
    }
    
    
    static func doHaptics_01(engine: CHHapticEngine?) {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        
        let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0)
        let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.5)
        
        let eventLong = CHHapticEvent(eventType: .hapticContinuous, parameters: [intensity, sharpness], relativeTime: 0, duration: 0.3)
        let eventShort = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: 0.3, duration: 0.1)
        
        playHaptics(engine: engine, events: [eventLong])
        playHaptics(engine: engine, events: [eventShort])
        playHaptics(engine: engine, events: [eventLong])
    }
    
    static func doHaptics_10(engine: CHHapticEngine?) {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        
        let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.8)
        let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.3)
        
        let eventLong = CHHapticEvent(eventType: .hapticContinuous, parameters: [intensity, sharpness], relativeTime: 0, duration: 0.3)
        let eventShort = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: 0.3, duration: 0.1)
        
        playHaptics(engine: engine, events: [eventShort])
        playHaptics(engine: engine, events: [eventLong])
        playHaptics(engine: engine, events: [eventShort])
    }
    
    static func doHaptics_11(engine: CHHapticEngine?) {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        
        let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0)
        let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 1.0)
        
        let eventLong = CHHapticEvent(eventType: .hapticContinuous, parameters: [intensity, sharpness], relativeTime: 0, duration: 0.3)
        let eventShort = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: 0.3, duration: 0.1)
        
        playHaptics(engine: engine, events: [eventLong])
        playHaptics(engine: engine, events: [eventLong])
        playHaptics(engine: engine, events: [eventShort])
    }
    
    
    
    static func doHaptics_02(engine: CHHapticEngine?) {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        let e1 = CHHapticEvent(eventType: .hapticTransient,
                               parameters: [
                                CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.7),
                                CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.2)
                               ],
                               relativeTime: 0)
        let e2 = CHHapticEvent(eventType: .hapticContinuous,
                               parameters: [
                                CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.3),
                                CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.8)
                               ],
                               relativeTime: 0.1, duration: 0.15)
        let e3 = CHHapticEvent(eventType: .hapticTransient,
                               parameters: [
                                CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0),
                                CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.5)
                               ],
                               relativeTime: 0.3)
        playHaptics(engine: engine, events: [e1, e2, e3])
    }
    
    static func doHaptics_03(engine: CHHapticEngine?) { // O
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        
        let attack1 = HapticManager.makeAttackBlock(attackTime: 0.1, sustainTime: 0.1, peakIntensity: 0.7, baseSharpness: 0.6, startTime: 0.0)
        let decay1 = HapticManager.makeDecayBlock(sustainTime: 0.1, decayTime: 0.2, peakIntensity: 0.7, endIntensity: 0.2, baseSharpness: 0.5, startTime: 0.0)
        let attack2 = HapticManager.makeAttackBlock(attackTime: 0.1, sustainTime: 0.1, peakIntensity: 0.7, baseSharpness: 0.6, startTime: 0.0)
        let decay2 = HapticManager.makeDecayBlock(sustainTime: 0.1, decayTime: 0.2, peakIntensity: 0.7, endIntensity: 0.2, baseSharpness: 0.5, startTime: 0.0)
        
        HapticManager.playCustomHaptic(engine: engine, blocks: [attack1])
         
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            HapticManager.playCustomHaptic(engine: engine, blocks: [decay1])
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
            HapticManager.playCustomHaptic(engine: engine, blocks: [attack2])
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            HapticManager.playCustomHaptic(engine: engine, blocks: [decay2])
        }
    }
    
    static func doHaptics_04(engine: CHHapticEngine?) { // P
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        
        let decay = HapticManager.makeDecayBlock(sustainTime: 0.2, decayTime: 0.1, peakIntensity: 0.8, endIntensity: 0.1, baseSharpness: 0.3, startTime: 0.0)
        let attack = HapticManager.makeAttackBlock(attackTime: 0.1, sustainTime: 0.1, peakIntensity: 0.8, baseSharpness: 0.3, startTime: 0.0)
        
        doHaptics_AttackDecay(engine: engine, attackTime: 0.0, sustainTime: 0.1, decayTime: 0.2, peakIntensity: 0.6, endIntensity: 0.3, baseSharpness: 0.7)
         
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            HapticManager.playCustomHaptic(engine: engine, blocks: [decay])
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
            HapticManager.playCustomHaptic(engine: engine, blocks: [attack])
        }
    }
    
    static func doHaptics_12(engine: CHHapticEngine?) {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        let e1 = CHHapticEvent(eventType: .hapticContinuous,
                               parameters: [
                                CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.4),
                                CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.6)
                               ],
                               relativeTime: 0, duration: 0.1)
        let e2 = CHHapticEvent(eventType: .hapticTransient,
                               parameters: [
                                CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.9),
                                CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.2)
                               ],
                               relativeTime: 0.12)
        let e3 = CHHapticEvent(eventType: .hapticContinuous,
                               parameters: [
                                CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.7),
                                CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.9)
                               ],
                               relativeTime: 0.2, duration: 0.1)
        playHaptics(engine: engine, events: [e1, e2, e3])
    }
    
    static func doHaptics_13(engine: CHHapticEngine?) { // K
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        
        let attack = HapticManager.makeAttackBlock(attackTime: 0.1, sustainTime: 0.1, peakIntensity: 0.7, baseSharpness: 0.6, startTime: 0.0)
        let decay = HapticManager.makeDecayBlock(sustainTime: 0.1, decayTime: 0.2, peakIntensity: 0.7, endIntensity: 0.2, baseSharpness: 0.5, startTime: 0.0)
        
        doHaptics_AttackDecay(engine: engine, attackTime: 0.0, sustainTime: 0.1, decayTime: 0.2, peakIntensity: 0.6, endIntensity: 0.3, baseSharpness: 0.7)
         
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            HapticManager.playCustomHaptic(engine: engine, blocks: [attack])
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            HapticManager.playCustomHaptic(engine: engine, blocks: [decay])
        }
    }
    
    static func doHaptics_14(engine: CHHapticEngine?) { // L
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }

        doHaptics_AttackDecay(engine: engine, attackTime: 0.0, sustainTime: 0.1, decayTime: 0.2, peakIntensity: 0.6, endIntensity: 0.3, baseSharpness: 0.7)
         
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            doHaptics_AttackDecay(engine: engine, attackTime: 0.01, sustainTime: 0.2, decayTime: 0.1, peakIntensity: 0.6, endIntensity: 0.6, baseSharpness: 0.6)
        }
    }
    
    static func doHaptics_20(engine: CHHapticEngine?) { // Z
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        let e1 = CHHapticEvent(eventType: .hapticTransient,
                               parameters: [
                                CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.5),
                                CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.8)
                               ],
                               relativeTime: 0)
        let e2 = CHHapticEvent(eventType: .hapticContinuous,
                               parameters: [
                                CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.7),
                                CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.2)
                               ],
                               relativeTime: 0.1, duration: 0.12)
        let e3 = CHHapticEvent(eventType: .hapticTransient,
                               parameters: [
                                CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0),
                                CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.4)
                               ],
                               relativeTime: 0.25)
        playHaptics(engine: engine, events: [e1, e2, e3])
    }
    
    static func doHaptics_21(engine: CHHapticEngine?) { // X
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        let e1 = CHHapticEvent(eventType: .hapticContinuous,
                               parameters: [
                                CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.6),
                                CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.6)
                               ],
                               relativeTime: 0, duration: 0.13)
        let e2 = CHHapticEvent(eventType: .hapticTransient,
                               parameters: [
                                CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.8),
                                CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.3)
                               ],
                               relativeTime: 0.14)
        let e3 = CHHapticEvent(eventType: .hapticContinuous,
                               parameters: [
                                CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.4),
                                CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.9)
                               ],
                               relativeTime: 0.2, duration: 0.1)
        playHaptics(engine: engine, events: [e1, e2, e3])
    }
    
    static func doHaptics_23(engine: CHHapticEngine?) { // N
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        
        let attack1 = HapticManager.makeAttackBlock(attackTime: 0.1, sustainTime: 0.1, peakIntensity: 0.8, baseSharpness: 0.3, startTime: 0.0)
        let decay = HapticManager.makeDecayBlock(sustainTime: 0.0, decayTime: 0.2, peakIntensity: 0.8, endIntensity: 0.2, baseSharpness: 0.7, startTime: 0.0)
        let attack2 = HapticManager.makeAttackBlock(attackTime: 0.1, sustainTime: 0.1, peakIntensity: 0.6, baseSharpness: 0.5, startTime: 0.0)
        
        HapticManager.playCustomHaptic(engine: engine, blocks: [attack1])
         
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            HapticManager.playCustomHaptic(engine: engine, blocks: [decay])
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            HapticManager.playCustomHaptic(engine: engine, blocks: [attack2])
        }
    }
    
    static func doHaptics_24(engine: CHHapticEngine?) { // M
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        
        let attack1 = HapticManager.makeAttackBlock(attackTime: 0.2, sustainTime: 0.1, peakIntensity: 0.8, baseSharpness: 0.3, startTime: 0.0)
        let decay1 = HapticManager.makeDecayBlock(sustainTime: 0.1, decayTime: 0.2, peakIntensity: 0.8, endIntensity: 0.3, baseSharpness: 0.3, startTime: 0.0)
        let attack2 = HapticManager.makeAttackBlock(attackTime: 0.2, sustainTime: 0.1, peakIntensity: 0.8, baseSharpness: 0.3, startTime: 0.0)
        let decay2 = HapticManager.makeDecayBlock(sustainTime: 0.1, decayTime: 0.2, peakIntensity: 0.8, endIntensity: 0.3, baseSharpness: 0.3, startTime: 0.0)
        
        HapticManager.playCustomHaptic(engine: engine, blocks: [attack1])
         
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            HapticManager.playCustomHaptic(engine: engine, blocks: [decay1])
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.55) {
            HapticManager.playCustomHaptic(engine: engine, blocks: [attack2])
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.85) {
            HapticManager.playCustomHaptic(engine: engine, blocks: [decay2])
        }
    }
    
    // (3,0) ~ (3,4)
    static func doHaptics_30(engine: CHHapticEngine?) { // E
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        let e1 = CHHapticEvent(eventType: .hapticContinuous,
                               parameters: [
                                CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.7),
                                CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.3)
                               ],
                               relativeTime: 0, duration: 0.12)
        let e2 = CHHapticEvent(eventType: .hapticTransient,
                               parameters: [
                                CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.5),
                                CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.6)
                               ],
                               relativeTime: 0.13)
        let e3 = CHHapticEvent(eventType: .hapticContinuous,
                               parameters: [
                                CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.8),
                                CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.4)
                               ],
                               relativeTime: 0.2, duration: 0.1)
        playHaptics(engine: engine, events: [e1, e2, e3])
    }
    
    static func doHaptics_31(engine: CHHapticEngine?) { // R
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        let e1 = CHHapticEvent(eventType: .hapticTransient,
                               parameters: [
                                CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.6),
                                CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.7)
                               ],
                               relativeTime: 0)
        let e2 = CHHapticEvent(eventType: .hapticContinuous,
                               parameters: [
                                CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.4),
                                CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.5)
                               ],
                               relativeTime: 0.1, duration: 0.13)
        let e3 = CHHapticEvent(eventType: .hapticTransient,
                               parameters: [
                                CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.9),
                                CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.2)
                               ],
                               relativeTime: 0.25)
        playHaptics(engine: engine, events: [e1, e2, e3])
    }
    
    static func doHaptics_33(engine: CHHapticEngine?) { // U
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        
        let decay = HapticManager.makeDecayBlock(sustainTime: 0.1, decayTime: 0.2, peakIntensity: 0.8, endIntensity: 0.3, baseSharpness: 0.3, startTime: 0.0)
        let attack = HapticManager.makeAttackBlock(attackTime: 0.2, sustainTime: 0.2, peakIntensity: 0.8, baseSharpness: 0.3, startTime: 0.0)
        HapticManager.playCustomHaptic(engine: engine, blocks: [decay])
         
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            HapticManager.playCustomHaptic(engine: engine, blocks: [attack])
        }
    }
    
    static func doHaptics_34(engine: CHHapticEngine?) { // I
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        doHaptics_AttackDecay(engine: engine, attackTime: 0.0, sustainTime: 0.1, decayTime: 0.2, peakIntensity: 0.6, endIntensity: 0.3, baseSharpness: 0.7)
    }
    
    // (4,0) ~ (4,4)
    static func doHaptics_40(engine: CHHapticEngine?) { // D
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        let e1 = CHHapticEvent(eventType: .hapticTransient,
                               parameters: [
                                CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.7),
                                CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.4)
                               ],
                               relativeTime: 0)
        let e2 = CHHapticEvent(eventType: .hapticContinuous,
                               parameters: [
                                CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.5),
                                CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.8)
                               ],
                               relativeTime: 0.1, duration: 0.13)
        let e3 = CHHapticEvent(eventType: .hapticTransient,
                               parameters: [
                                CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.6),
                                CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.6)
                               ],
                               relativeTime: 0.25)
        playHaptics(engine: engine, events: [e1, e2, e3])
    }
    
    static func doHaptics_41(engine: CHHapticEngine?) { // F
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        let e1 = CHHapticEvent(eventType: .hapticContinuous,
                               parameters: [
                                CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.4),
                                CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.7)
                               ],
                               relativeTime: 0, duration: 0.12)
        let e2 = CHHapticEvent(eventType: .hapticTransient,
                               parameters: [
                                CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.8),
                                CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.3)
                               ],
                               relativeTime: 0.13)
        let e3 = CHHapticEvent(eventType: .hapticContinuous,
                               parameters: [
                                CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.6),
                                CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.5)
                               ],
                               relativeTime: 0.2, duration: 0.1)
        playHaptics(engine: engine, events: [e1, e2, e3])
    }
    
    static func doHaptics_42(engine: CHHapticEngine?) { // space
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        let e1 = CHHapticEvent(eventType: .hapticTransient,
                               parameters: [
                                CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.3),
                                CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.9)
                               ],
                               relativeTime: 0)
        let e2 = CHHapticEvent(eventType: .hapticContinuous,
                               parameters: [
                                CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.7),
                                CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.2)
                               ],
                               relativeTime: 0.1, duration: 0.14)
        let e3 = CHHapticEvent(eventType: .hapticTransient,
                               parameters: [
                                CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.5),
                                CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.7)
                               ],
                               relativeTime: 0.26)
        playHaptics(engine: engine, events: [e1, e2, e3])
    }
    
    static func doHaptics_43(engine: CHHapticEngine?) { // H
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }

        doHaptics_AttackDecay(engine: engine, attackTime: 0.0, sustainTime: 0.1, decayTime: 0.2, peakIntensity: 0.6, endIntensity: 0.3, baseSharpness: 0.7)
         
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            doHaptics_AttackDecay(engine: engine, attackTime: 0.01, sustainTime: 0.2, decayTime: 0.1, peakIntensity: 0.6, endIntensity: 0.6, baseSharpness: 0.7)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            doHaptics_AttackDecay(engine: engine, attackTime: 0.0, sustainTime: 0.1, decayTime: 0.2, peakIntensity: 0.6, endIntensity: 0.3, baseSharpness: 0.7)
        }
    }
    
    static func doHaptics_44(engine: CHHapticEngine?) { // J
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        
        let decay = HapticManager.makeDecayBlock(sustainTime: 0.2, decayTime: 0.1, peakIntensity: 0.8, endIntensity: 0.1, baseSharpness: 0.3, startTime: 0.0)
        let attack = HapticManager.makeAttackBlock(attackTime: 0.1, sustainTime: 0.1, peakIntensity: 0.6, baseSharpness: 0.7, startTime: 0.0)
        HapticManager.playCustomHaptic(engine: engine, blocks: [decay])
         
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            HapticManager.playCustomHaptic(engine: engine, blocks: [attack])
        }
    }
    
    // (5,0) ~ (5,4)
    static func doHaptics_50(engine: CHHapticEngine?) { // C
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        let e1 = CHHapticEvent(eventType: .hapticContinuous,
                               parameters: [
                                CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.7),
                                CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.3)
                               ],
                               relativeTime: 0, duration: 0.12)
        let e2 = CHHapticEvent(eventType: .hapticTransient,
                               parameters: [
                                CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.5),
                                CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.6)
                               ],
                               relativeTime: 0.13)
        let e3 = CHHapticEvent(eventType: .hapticContinuous,
                               parameters: [
                                CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.8),
                                CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.4)
                               ],
                               relativeTime: 0.2, duration: 0.1)
        playHaptics(engine: engine, events: [e1, e2, e3])
    }
    
    static func doHaptics_51(engine: CHHapticEngine?) { // V
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        let e1 = CHHapticEvent(eventType: .hapticTransient,
                               parameters: [
                                CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.6),
                                CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.7)
                               ],
                               relativeTime: 0)
        let e2 = CHHapticEvent(eventType: .hapticContinuous,
                               parameters: [
                                CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.4),
                                CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.5)
                               ],
                               relativeTime: 0.1, duration: 0.13)
        let e3 = CHHapticEvent(eventType: .hapticTransient,
                               parameters: [
                                CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.9),
                                CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.2)
                               ],
                               relativeTime: 0.25)
        playHaptics(engine: engine, events: [e1, e2, e3])
    }
    
    static func doHaptics_53(engine: CHHapticEngine?) { // B
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        
        let attack = HapticManager.makeAttackBlock(attackTime: 0.1, sustainTime: 0.1, peakIntensity: 0.8, baseSharpness: 0.3, startTime: 0.0)
        let decay = HapticManager.makeDecayBlock(sustainTime: 0.2, decayTime: 0.1, peakIntensity: 0.8, endIntensity: 0.1, baseSharpness: 0.3, startTime: 0.0)
        
        doHaptics_AttackDecay(engine: engine, attackTime: 0.0, sustainTime: 0.1, decayTime: 0.2, peakIntensity: 0.6, endIntensity: 0.3, baseSharpness: 0.7)
         
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            HapticManager.playCustomHaptic(engine: engine, blocks: [attack])
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
            HapticManager.playCustomHaptic(engine: engine, blocks: [decay])
        }
    }
    
    static func doHaptics_54(engine: CHHapticEngine?) { // Y
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        
        let attack = HapticManager.makeAttackBlock(attackTime: 0.05, sustainTime: 0.1, peakIntensity: 0.7, baseSharpness: 0.8, startTime: 0.0)
        let decay = HapticManager.makeDecayBlock(sustainTime: 0.3, decayTime: 0.3, peakIntensity: 0.7, endIntensity: 0.1, baseSharpness: 0.3, startTime: 0.0)
        
        HapticManager.playCustomHaptic(engine: engine, blocks: [attack])
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            HapticManager.playCustomHaptic(engine: engine, blocks: [decay])
        }
    }
    
    // (6,0) ~ (6,4)
    static func doHaptics_60(engine: CHHapticEngine?) { // T
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        let e1 = CHHapticEvent(eventType: .hapticTransient,
                               parameters: [
                                CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.7),
                                CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.4)
                               ],
                               relativeTime: 0)
        let e2 = CHHapticEvent(eventType: .hapticContinuous,
                               parameters: [
                                CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.5),
                                CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.8)
                               ],
                               relativeTime: 0.1, duration: 0.13)
        let e3 = CHHapticEvent(eventType: .hapticTransient,
                               parameters: [
                                CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.6),
                                CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.6)
                               ],
                               relativeTime: 0.25)
        playHaptics(engine: engine, events: [e1, e2, e3])
    }
    
    static func doHaptics_61(engine: CHHapticEngine?) { // G
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        let e1 = CHHapticEvent(eventType: .hapticContinuous,
                               parameters: [
                                CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.4),
                                CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.7)
                               ],
                               relativeTime: 0, duration: 0.12)
        let e2 = CHHapticEvent(eventType: .hapticTransient,
                               parameters: [
                                CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.8),
                                CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.3)
                               ],
                               relativeTime: 0.13)
        let e3 = CHHapticEvent(eventType: .hapticContinuous,
                               parameters: [
                                CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.6),
                                CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.5)
                               ],
                               relativeTime: 0.2, duration: 0.1)
        playHaptics(engine: engine, events: [e1, e2, e3])
    }
    
    static func doHaptics_62(engine: CHHapticEngine?) { // enter
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        let e1 = CHHapticEvent(eventType: .hapticTransient,
                               parameters: [
                                CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.3),
                                CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.9)
                               ],
                               relativeTime: 0)
        let e2 = CHHapticEvent(eventType: .hapticContinuous,
                               parameters: [
                                CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.7),
                                CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.2)
                               ],
                               relativeTime: 0.1, duration: 0.14)
        let e3 = CHHapticEvent(eventType: .hapticTransient,
                               parameters: [
                                CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.5),
                                CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.7)
                               ],
                               relativeTime: 0.26)
        playHaptics(engine: engine, events: [e1, e2, e3])
    }
    
    static func doHaptics_63(engine: CHHapticEngine?) { // ,
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        
        let decay = HapticManager.makeDecayBlock(sustainTime: 0.2, decayTime: 0.1, peakIntensity: 0.7, endIntensity: 0.1, baseSharpness: 0.7, startTime: 0.0)
        
        HapticManager.playCustomHaptic(engine: engine, blocks: [decay])
    }
    
    static func doHaptics_64(engine: CHHapticEngine?) { // ?
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        
        let attack1 = HapticManager.makeAttackBlock(attackTime: 0.1, sustainTime: 0.1, peakIntensity: 0.8, baseSharpness: 0.7, startTime: 0.0)
        let decay = HapticManager.makeDecayBlock(sustainTime: 0.1, decayTime: 0.1, peakIntensity: 0.8, endIntensity: 0.3, baseSharpness: 0.3, startTime: 0.0)
        let attack2 = HapticManager.makeAttackBlock(attackTime: 0.0, sustainTime: 0.1, peakIntensity: 0.7, baseSharpness: 0.7, startTime: 0.0)
        
        HapticManager.playCustomHaptic(engine: engine, blocks: [attack1])
         
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            HapticManager.playCustomHaptic(engine: engine, blocks: [decay])
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            HapticManager.playCustomHaptic(engine: engine, blocks: [attack2])
        }
    }
}

