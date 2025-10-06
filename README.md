# 🎬 DemoYacht — tvOS SwiftUI Crew Viewer

> A clean, elegant Apple TV (tvOS) app built with **SwiftUI** and **Combine** that showcases the SuperYacht crew list.  
> Designed to feel cinematic and fluid on the big screen — with smooth focus transitions, cached images, and automatic data refresh.

---

## 📺 Overview

DemoYacht is a lightweight tvOS app that displays a dynamic list of yacht crew members.  
It fetches real data from the **SuperYacht API**, shows a rich visual grid of crew profiles,  
and lets the user explore details with fullscreen immersive modals.

https://github.com/yourname/DemoYacht/assets/demo-preview.gif

---

## 🚀 Features

| Feature | Description |
|----------|-------------|
| **📡 Live API Integration** | Data fetched from [`/resources/crew`](https://collector-dev.superyachtapi.com/resources/crew) |
| **🕓 Auto-Refresh** | Refreshes every 30 seconds without blocking the UI |
| **💾 Image Caching** | On-device in-memory cache to avoid refetching |
| **🔢 Sorting & Filtering** | Sorted by department → crew order, plus segmented department filter |
| **🧭 Focus Navigation** | Full tvOS focus handling with lift, glow, and smooth scaling |
| **🌌 Fullscreen Detail View** | Immersive profile screen with bio, country flag, and high-res photo |
| **🖼️ Graceful Placeholders** | Automatically fills empty or missing data with defaults |
| **💬 Combine + Swift Concurrency** | Used for publishers, async/await, and periodic refresh |
| **🧱 Clean Architecture** | Layered into `Models`, `Networking`, `ViewModels`, and `Views` |

---

## 🏗️ Architecture

DemoYacht/
├── Models/
│   ├── CrewMember.swift
│   ├── Department.swift
│   └── SafeDecoding.swift
├── Networking/
│   ├── APIService.swift
│   └── ImageLoader.swift
├── ViewModels/
│   └── CrewViewModel.swift
├── Views/
│   ├── HomeScreen.swift
│   ├── CrewCardView.swift
│   ├── RemoteCrewCardView.swift
│   ├── CrewDetailView.swift
│   ├── AvatarPlaceholderView.swift
│   └── FocusStyles.swift
└── DemoYachtApp.swift


- **Models**: Codable entities and safe default decoding  
- **Networking**: Generic REST API service + async image caching  
- **ViewModels**: Business logic & periodic refresh  
- **Views**: Pure SwiftUI layers, tvOS-optimized focus animations

---

## ⚙️ API Reference

- **Crew list**  
  `GET https://collector-dev.superyachtapi.com/resources/crew`

- **Image download**  
  `GET https://collector-dev.superyachtapi.com/files/download/<path>`

Each crew member includes:
```json
{
  "_id": "6707bc1db70e0bfc0668e218",
  "name": "Laurent Dubois",
  "role": "Developer",
  "country": "DZ",
  "age": 90,
  "order": 0,
  "path": "urn:mrn:yachteye:s3:68c18d456fe1c3a65b110e30"
}
