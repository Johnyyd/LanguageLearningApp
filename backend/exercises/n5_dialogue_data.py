# -*- coding: utf-8 -*-

N5_DIALOGUE_SCENARIOS = [
    {
        "id": "sc_01",
        "title": "Chào hỏi & Giới thiệu bản thân",
        "subtitle": "Hội thoại lần đầu gặp mặt (Tự giới thiệu tên, quốc tịch)",
        "icon": "greeting",
        "color": "#58CC02",
        "turns": [
            {
                "speaker": "Sensei",
                "japanese": "はじめまして。私はセンセイです。お名前は何ですか？",
                "romaji": "Hajimemashite. Watashi wa Sensei desu. Onamae wa nan desu ka?",
                "vietnamese": "Rất vui được gặp bạn. Tôi là Sensei. Tên bạn là gì?"
            },
            {
                "speaker": "User",
                "japanese": "はじめまして。私はナムです。ベトナムから来ました。",
                "romaji": "Hajimemashite. Watashi wa Namu desu. Betonamu kara kimashita.",
                "vietnamese": "Rất vui được gặp cô. Tôi là Nam. Tôi đến từ Việt Nam."
            },
            {
                "speaker": "Sensei",
                "japanese": "そうですか。よろしく お願いします。",
                "romaji": "Sou desu ka. Yoroshiku onegaishimasu.",
                "vietnamese": "Vậy à. Rất mong được giúp đỡ."
            },
            {
                "speaker": "User",
                "japanese": "こちらこそ、よろしく お願いします。",
                "romaji": "Kochirakoso, yoroshiku onegaishimasu.",
                "vietnamese": "Chính tôi mới mong được giúp đỡ ạ."
            }
        ]
    },
    {
        "id": "sc_02",
        "title": "Mua sắm tại cửa hàng tiện lợi",
        "subtitle": "Hỏi giá cả và thanh toán tại Konbini",
        "icon": "shopping",
        "color": "#1CB0F6",
        "turns": [
            {
                "speaker": "Sensei",
                "japanese": "いらっしゃいませ。何を お探しですか？",
                "romaji": "Irasshaimase. Nani o osagashi desu ka?",
                "vietnamese": "Kính chào quý khách. Quý khách đang tìm gì ạ?"
            },
            {
                "speaker": "User",
                "japanese": "すみません、この お弁当は いくらですか？",
                "romaji": "Sumimasen, kono obentou wa ikura desu ka?",
                "vietnamese": "Xin lỗi, hộp cơm bento này giá bao nhiêu tiền?"
            },
            {
                "speaker": "Sensei",
                "japanese": "それは 450円 です。温めますか？",
                "romaji": "Sore wa yonhyaku gojuu en desu. Atatamemasu ka?",
                "vietnamese": "Cái đó 450 Yên ạ. Quý khách có muốn hâm nóng không?"
            },
            {
                "speaker": "User",
                "japanese": "はい、お願いします。これで お願いします。",
                "romaji": "Hai, onegaishimasu. Kore de onegaishimasu.",
                "vietnamese": "Vâng, nhờ cô hâm nóng giúp. Tôi gửi tiền đây."
            }
        ]
    },
    {
        "id": "sc_03",
        "title": "Hỏi đường đi nhà ga tàu điện",
        "subtitle": "Hỏi hướng đi và vị trí nhà ga gần nhất",
        "icon": "train",
        "color": "#FFC800",
        "turns": [
            {
                "speaker": "User",
                "japanese": "すみません、駅は どこですか？",
                "romaji": "Sumimasen, eki wa doko desu ka?",
                "vietnamese": "Xin lỗi làm ơn cho hỏi, nhà ga ở đâu vậy?"
            },
            {
                "speaker": "Sensei",
                "japanese": "駅ですね。あそこを まっすぐ行って、右に曲がってください。",
                "romaji": "Eki desu ne. Asoko o massugu itte, migi ni magatte kudasai.",
                "vietnamese": "Nhà ga nhỉ. Bạn đi thẳng chỗ kia rồi rẽ phải nhé."
            },
            {
                "speaker": "User",
                "japanese": "ありがとうございます。歩いて 何分くらい かかりますか？",
                "romaji": "Arigatou gozaimasu. Aruite nanpun kurai kakarimasu ka?",
                "vietnamese": "Cảm ơn cô nhiều. Đi bộ khoảng bao nhiêu phút ạ?"
            },
            {
                "speaker": "Sensei",
                "japanese": "歩いて 5分くらい ですよ。気をつけてください。",
                "romaji": "Aruite gopun kurai desu yo. Ki o tsukete kudasai.",
                "vietnamese": "Đi bộ mất khoảng 5 phút thôi. Bạn đi cẩn thận nhé."
            }
        ]
    }
]
