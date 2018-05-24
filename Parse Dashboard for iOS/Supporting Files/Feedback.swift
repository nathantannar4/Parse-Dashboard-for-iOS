//
//  Feedback.swift
//  Evocial
//
//  Created by Nathan Tannar on 4/21/18.
//  Copyright © 2018 Amanda Hille. All rights reserved.
//

import FeedbackGenerator

func generateFeedback() {
    let feedback = Feedback(hapticType: Feedback.HapticType.impact(.heavy), soundType: Feedback.SoundType.impact(.medium))
    feedback.prepareForUse()
    feedback.generateFeedback()
}

