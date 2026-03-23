-- =========================================
-- Seed Data
-- =========================================
USE acadbeat;
-- users
INSERT INTO users (username, email, password_hash, avatar_url)
VALUES
('alice', 'alice@example.com', 'hashed_pw_1', 'https://example.com/avatar/alice.png'),
('bob', 'bob@example.com', 'hashed_pw_2', 'https://example.com/avatar/bob.png'),
('carol', 'carol@example.com', 'hashed_pw_3', NULL);

-- training_modules
INSERT INTO training_modules (title, description, skill_type, status)
VALUES
(
    'Short Lecture Listening Practice 1',
    'Listen to a short classroom audio and answer comprehension questions.',
    'listening',
    'published'
),
(
    'Listen and Retell Practice 1',
    'Listen to a short passage and retell it in your own words.',
    'integrated',
    'published'
);

-- training_items
INSERT INTO training_items (module_id, item_type, title, prompt_text, order_index, points)
VALUES
(1, 'audio_comprehension', 'Main Idea Question', 'Listen carefully and choose the best answer.', 1, 2),
(1, 'audio_comprehension', 'Detail Question', 'Answer the question based on the lecture detail.', 2, 2),
(2, 'listen_retell', 'Retell Task', 'Listen to the audio and retell the content.', 1, 5);

-- training_item_configs
INSERT INTO training_item_configs (item_id, content_data, answer_data)
VALUES
(
    1,
    JSON_OBJECT(
        'audio_url', 'https://example.com/audio/lecture1.mp3',
        'question_text', 'What is the main topic of the lecture?',
        'options', JSON_ARRAY('Time management', 'Academic writing', 'Library rules', 'Group discussion'),
        'allow_replay', true
    ),
    JSON_OBJECT(
        'correct_answer', 'Academic writing',
        'explanation', 'The speaker mainly discusses key features of academic writing.'
    )
),
(
    2,
    JSON_OBJECT(
        'audio_url', 'https://example.com/audio/lecture1.mp3',
        'question_text', 'What does the speaker suggest students avoid?',
        'options', JSON_ARRAY('Formal tone', 'Informal expressions', 'Planning', 'Editing'),
        'allow_replay', true
    ),
    JSON_OBJECT(
        'correct_answer', 'Informal expressions',
        'explanation', 'The lecture says academic writing should avoid informal expressions.'
    )
),
(
    3,
    JSON_OBJECT(
        'audio_url', 'https://example.com/audio/retell1.mp3',
        'instruction', 'Retell the passage in your own words.',
        'time_limit_seconds', 90
    ),
    JSON_OBJECT(
        'reference_text', 'The passage explains how students can prepare before attending an academic seminar.',
        'keywords', JSON_ARRAY('prepare', 'seminar', 'notes', 'questions')
    )
);

-- training_attempts
INSERT INTO training_attempts (user_id, module_id, status, started_at, submitted_at, total_score)
VALUES
(1, 1, 'graded', '2026-03-22 09:00:00', '2026-03-22 09:10:00', 4.00),
(2, 2, 'submitted', '2026-03-22 10:00:00', '2026-03-22 10:08:00', NULL);

-- training_responses
INSERT INTO training_responses (attempt_id, item_id, response_data, score, submitted_at)
VALUES
(
    1,
    1,
    JSON_OBJECT('selected_option', 'Academic writing'),
    2.00,
    '2026-03-22 09:05:00'
),
(
    1,
    2,
    JSON_OBJECT('selected_option', 'Informal expressions'),
    2.00,
    '2026-03-22 09:08:00'
),
(
    2,
    3,
    JSON_OBJECT(
        'audio_url', 'https://example.com/uploads/retell_bob_1.mp3',
        'transcript', 'The speaker talks about preparing for a seminar by reading materials and making notes first.'
    ),
    NULL,
    '2026-03-22 10:08:00'
);

-- forum_posts
INSERT INTO forum_posts (user_id, title, content_text, view_count, comment_count, last_commented_at, status)
VALUES
(
    1,
    'How do you improve academic listening?',
    'I often miss details in short lecture clips. Any advice?',
    15,
    2,
    '2026-03-22 11:20:00',
    'active'
),
(
    2,
    'Useful Teams features for study groups',
    'Here are some Teams features that help with group study.',
    8,
    1,
    '2026-03-22 12:00:00',
    'active'
);

-- forum_post_media
INSERT INTO forum_post_media (post_id, media_type, media_url, order_index)
VALUES
(1, 'link', 'https://support.microsoft.com/en-us/teams', 1),
(2, 'image', 'https://example.com/media/teams-tips.png', 1),
(2, 'link', 'https://www.microsoft.com/en/microsoft-teams/group-chat-software', 2);

-- forum_comments
INSERT INTO forum_comments (post_id, user_id, parent_comment_id, content_text, status)
VALUES
(1, 2, NULL, 'Try listening once for the main idea and again for details.', 'active'),
(1, 3, 1, 'Yes, and taking quick notes also helps a lot.', 'active'),
(2, 1, NULL, 'The meeting recording feature is also useful.', 'active');

-- forum_comment_media
INSERT INTO forum_comment_media (comment_id, media_type, media_url, order_index)
VALUES
(2, 'audio', 'https://example.com/media/comment-audio-1.mp3', 1),
(3, 'link', 'https://support.microsoft.com/en-us/office/record-a-meeting-in-microsoft-teams', 1);

-- forum_labels
INSERT INTO forum_labels (name)
VALUES
('listening'),
('speaking'),
('study_tips'),
('question_help'),
('digital_tools');

-- forum_post_labels
INSERT INTO forum_post_labels (post_id, label_id)
VALUES
(1, 1),
(1, 3),
(1, 4),
(2, 5);

-- checkin_partnerships
INSERT INTO checkin_partnerships (user_one_id, user_two_id, status)
VALUES
(1, 2, 'active'),
(2, 3, 'active');

-- checkin_records
INSERT INTO checkin_records (partnership_id, user_id, checkin_date)
VALUES
(1, 1, '2026-03-22'),
(1, 2, '2026-03-22'),
(2, 2, '2026-03-22');