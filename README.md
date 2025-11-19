<div align="center">
  <img src="https://raw.githubusercontent.com/Andreas-Garcia/audiometa/main/assets/logo.png" alt="AudioMeta Logo" width="150"/>
  
  # Hi, I'm Andreas Garcia 👋
  
  **Full-Stack Developer | Founder & Lead Developer | Music Technology Innovator | Open Source Contributor**
  
  [![GitHub followers](https://img.shields.io/github/followers/Andreas-Garcia?label=Follow&style=social)](https://github.com/Andreas-Garcia)
[![GitHub stars](https://img.shields.io/github/stars/Andreas-Garcia?label=Total%20Stars&style=social)](https://github.com/Andreas-Garcia)
[![GitHub contributions](https://img.shields.io/github/contributors/Andreas-Garcia/Andreas-Garcia?label=Contributions&style=social)](https://github.com/Andreas-Garcia)
</div>

## 🎵 About Me

I'm a **full-stack developer** passionate about building open-source tools and platforms that empower music lovers, developers, and creators. I love creating solutions that combine technical excellence with real-world impact, focusing on music technology, metadata management, and community-driven innovation.

I build with **Python**, **Django REST Framework**, **Next.js**, **TypeScript**, and **React**, always following clean code principles and best practices. When I'm not coding, I'm contributing to open-source projects, collaborating with communities, or working on music-related initiatives that make a difference.

**Languages:** 🇫🇷 French (Native) | 🇬🇧 English (Advanced) | 🇪🇸 Spanish (Advanced) | 🇩🇪 German (Basic)

## 🚀 Featured Projects

### [AudioMeta Python](https://github.com/Andreas-Garcia/audiometa)

A powerful, unified Python library for reading and writing audio metadata across multiple formats. Supports ID3v1, ID3v2, Vorbis, and RIFF metadata formats through a single, consistent API.

[![GitHub stars](https://img.shields.io/github/stars/Andreas-Garcia/audiometa?style=social)](https://github.com/Andreas-Garcia/audiometa/stargazers)
[![PyPI version](https://img.shields.io/pypi/v/audiometa-python)](https://pypi.org/project/audiometa-python/)
[![Downloads](https://img.shields.io/pepy/dt/audiometa-python)](https://pepy.tech/project/audiometa-python)

**Key Features:**

- ✅ Unified API for all audio formats
- ✅ Comprehensive metadata field support
- ✅ Production-ready with 500+ tests
- ✅ Cross-platform (Windows, macOS, Linux)
- ✅ Extensive documentation

**Installation:**

```bash
pip install audiometa-python
```

**Quick Example:**

```python
from audiometa import get_unified_metadata, update_metadata, UnifiedMetadataKey

# Read metadata
metadata = get_unified_metadata("song.mp3")
print(f"Title: {metadata.get(UnifiedMetadataKey.TITLE)}")

# Update metadata
update_metadata("song.mp3", {
    UnifiedMetadataKey.TITLE: "New Title",
    UnifiedMetadataKey.ARTISTS: ["Artist Name"]
})
```

---

### 🎶 BehindTheMusicTree: Empowering Music Discovery and Organization

**BehindTheMusicTree** is an ecosystem that encompasses three interconnected projects designed to revolutionize how we explore, understand, and organize music. By blending cutting-edge AI, community-driven intelligence, and a robust, evolving framework, these projects work together to provide a holistic music experience for music lovers, collectors, and professionals alike.

The ecosystem includes:

#### 🌳 GrowTheMusicTree: Building the Ultimate Music Genre Reference

> 🔨 **Work in Progress** - Will be published open source soon! 🚀

At the core of **BehindTheMusicTree** lies **GrowTheMusicTree**, a groundbreaking platform focused on **building the definitive, interactive map of global music genres**. This ambitious project aims to become the **ultimate reference** for understanding music genres—past, present, and future—by constructing an ever-evolving, tree-shaped framework that organizes genres, subgenres, and microgenres based on their musical characteristics, historical context, and cultural relevance.

By continuously evolving through **community-driven curation**, expert input, and AI-powered tools, this platform offers the most comprehensive and dynamic structure for exploring music genres. The goal is to create a shared, credible, and universally accessible reference that helps anyone—from casual listeners to professionals—navigate and understand the world of music.

**Key features:**

- **A dynamic, evolving genre tree**, collaboratively built by users and experts
- **Personalized music journeys** that visually map users' listening habits within the genre tree, enabling niche genres discovery
- **AI-powered genre detection** that accurately categorizes any track, even those outside mainstream genres
- **API access** through **GetTheMusicTree** allows developers and professionals to integrate genre intelligence into their platforms

**Technical Stack:** Next.js, TypeScript, React, JavaScript, Docker, GitFlow, GitHub Actions CI/CD

#### 🔌 GetTheMusicTree: The Music Genre API

> 🔨 **Work in Progress** - Will be published open source soon! 🚀

**GetTheMusicTree** is the API companion to **GrowTheMusicTree**, giving developers, researchers, and music platforms access to the full genre hierarchy, detailed metadata, and AI-powered genre detection. Built with **Django REST Framework** and **PostgreSQL**, it enables personalized user profiling based on listening habits, delivers accurate track and artist classifications, and provides data-driven recommendations. Perfect for powering music discovery, streaming personalization, event recommendations, and listener analytics, **GetTheMusicTree** brings the intelligence of the genre tree to any app or service.

**Technical Stack:** Python, Django REST Framework, PostgreSQL, Docker, GitHub Actions CI/CD

#### 🎧 InTheMusicTree: A Smart Cloud-Based Music Library Manager

Powered by the genre intelligence of **GrowTheMusicTree** and integrated with the **GetTheMusicTree API**, **InTheMusicTree** is a **cloud-based audio file manager** built for collectors, DJs, and music lovers who want full control over their libraries. It uses automatic genre detection, deep metadata analysis, and real-time insights from the API to help users seamlessly organize, stream, and explore their collections—leveraging the **ultimate genre reference** to its fullest potential.

**Key features:**

- **Smart, adaptive playlists** generated based on style, subgenre, era, and more
- **Universal format and tag support** for seamless integration with all your tools and devices
- **Secure cloud storage** for backup and access across all your devices
- **Discover and purchase new music** via links to Bandcamp, Beatport, and JunoDownload
- **Cross-platform sync** and **export** to streaming and DJ/production software for creative workflows

## 🛠️ Technologies & Tools

### Backend

![Python](https://img.shields.io/badge/Python-3.12+-3776AB?style=flat-square&logo=python&logoColor=white)
![Django](https://img.shields.io/badge/Django_REST_Framework-092E20?style=flat-square&logo=django&logoColor=white)
![Java](https://img.shields.io/badge/Java_Spring_Boot-ED8B00?style=flat-square&logo=spring&logoColor=white)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-316192?style=flat-square&logo=postgresql&logoColor=white)
![SQL](https://img.shields.io/badge/SQL-4479A1?style=flat-square&logo=postgresql&logoColor=white)

### Frontend

![TypeScript](https://img.shields.io/badge/TypeScript-007ACC?style=flat-square&logo=typescript&logoColor=white)
![JavaScript](https://img.shields.io/badge/JavaScript-F7DF1E?style=flat-square&logo=javascript&logoColor=black)
![Next.js](https://img.shields.io/badge/Next.js-000000?style=flat-square&logo=next.js&logoColor=white)
![React](https://img.shields.io/badge/React-61DAFB?style=flat-square&logo=react&logoColor=black)

### DevOps & Tools

![Docker](https://img.shields.io/badge/Docker-2496ED?style=flat-square&logo=docker&logoColor=white)
![Git](https://img.shields.io/badge/Git-F05032?style=flat-square&logo=git&logoColor=white)
![GitHub Actions](https://img.shields.io/badge/GitHub_Actions-2088FF?style=flat-square&logo=github-actions&logoColor=white)
![GitFlow](https://img.shields.io/badge/GitFlow-F05032?style=flat-square&logo=git&logoColor=white)
![PyPI](https://img.shields.io/badge/PyPI-3775A9?style=flat-square&logo=pypi&logoColor=white)

### Testing & Quality

![pytest](https://img.shields.io/badge/pytest-0A9EDC?style=flat-square&logo=pytest&logoColor=white)
![mypy](https://img.shields.io/badge/mypy-000000?style=flat-square&logo=python&logoColor=white)
![ruff](https://img.shields.io/badge/ruff-000000?style=flat-square&logo=ruff&logoColor=white)

### Methodologies

![SCRUM](https://img.shields.io/badge/SCRUM-6DB33F?style=flat-square&logo=scrumalliance&logoColor=white)
![Clean Code](https://img.shields.io/badge/Clean_Code-000000?style=flat-square&logo=code&logoColor=white)

## 📊 GitHub Stats

<div align="center">
  
  ![GitHub Stats](https://github-readme-stats.vercel.app/api?username=Andreas-Garcia&show_icons=true&theme=radical&hide_border=true&count_private=true&include_all_commits=true)
  
  ![Top Languages](https://github-readme-stats.vercel.app/api/top-langs/?username=Andreas-Garcia&layout=compact&theme=radical&hide_border=true&langs_count=8)
  
</div>

<div align="center">
  
  ![GitHub Streak](https://github-readme-streak-stats.herokuapp.com/?user=Andreas-Garcia&theme=radical&hide_border=true)
  
</div>

<div align="center">
  
  ![GitHub Activity Graph](https://github-readme-activity-graph.vercel.app/graph?username=Andreas-Garcia&theme=radical&hide_border=true&area=true)
  
</div>

## 🤝 Open Source Contributions

I'm passionate about open-source development and believe in building tools that benefit the community. Here's how I contribute:

### 🎯 Active Projects

- **[AudioMeta Python](https://github.com/Andreas-Garcia/audiometa)** - Maintainer and primary contributor

  - Production-ready library with 500+ tests
  - Comprehensive documentation and examples
  - Active issue triage and community support
  - Regular releases and feature updates

- **BehindTheMusicTree** - Ecosystem Founder & Lead Developer
  - **GrowTheMusicTree**: Community-driven genre classification platform (coming soon)
  - **GetTheMusicTree**: API for developers and researchers (coming soon)
  - **InTheMusicTree**: Cloud-based music library manager (coming soon)

### 🌿 Contributions to Other Projects

- **[OpenSILEX](https://github.com/OpenSILEX/opensilex)** - Contributor
  - Contributed to open-source information systems for making research data FAIR (Findable, Accessible, Interoperable, Reusable)
  - Worked on backend services and ontology improvements for research data management

### 🌱 How I Contribute

- **Code Contributions**: Building and maintaining open-source libraries
- **Documentation**: Writing clear docs and examples to help others
- **Community Support**: Answering questions, triaging issues, reviewing PRs
- **Best Practices**: Following clean code principles, comprehensive testing, CI/CD automation
- **Knowledge Sharing**: Sharing learnings through discussions and contributions

### 💡 Open Source Values

I believe open-source software should be:

- **Well-tested** - Comprehensive test coverage ensures reliability
- **Well-documented** - Clear documentation helps everyone succeed
- **Community-driven** - Built with and for the community
- **Production-ready** - Tools that people can trust in real projects

## 📝 Recent Activity

<!--START_SECTION:activity-->
<!--END_SECTION:activity-->

## 🏆 GitHub Achievements

<div align="center">
  
  ![GitHub Trophies](https://github-profile-trophy.vercel.app/?username=Andreas-Garcia&theme=radical&no-frame=true&no-bg=true&column=7)
  
</div>

## 🌍 A Global Vision for Music Culture

The **BehindTheMusicTree** ecosystem is committed to creating a **global, authoritative reference** that serves as the foundation for music discovery, exploration, and understanding. Through **GrowTheMusicTree**, **InTheMusicTree**, and **GetTheMusicTree**, we offer a comprehensive framework that reflects the full diversity of global music culture.

Through the combined power of **AI, expert curation, developer tools, and community collaboration**, we're building a future where everyone—from casual listeners to creators to engineers—can connect more deeply with music.

**Join us in building the ultimate music genre reference and transforming the way the world navigates and understands music—where your journey, your collection, and your community thrive.**

## 🤝 Contributing & Collaboration

I **love** collaborating with the community! Contributions make projects better for everyone.

### How You Can Contribute

**🐛 Found a bug?** Open an issue with details and steps to reproduce.

**💡 Have an idea?** Share it in discussions or open a feature request.

**🔧 Want to code?** Check out open issues, fork the repo, and submit a PR!

**📝 See a typo?** Documentation improvements are always welcome.

**⭐ Like a project?** Starring helps others discover it.

**📢 Share it!** Tell others about projects you find useful.

### Contribution Guidelines

For **AudioMeta Python**, see the [Contributing Guidelines](https://github.com/Andreas-Garcia/audiometa/blob/main/CONTRIBUTING.md) - they cover:

- Development setup
- Code style and conventions
- Testing requirements
- Commit message format
- PR process

### What Makes a Great Contribution

- **Clear communication** - Describe what and why
- **Small, focused changes** - Easier to review and merge
- **Tests included** - Ensures quality and prevents regressions
- **Documentation updates** - Keep docs in sync with code
- **Respectful collaboration** - We're all here to learn and build together

**Every contribution matters**, no matter how small! 🎉

## 📫 Connect With Me

- 💼 **LinkedIn**: [Connect on LinkedIn](https://www.linkedin.com/in/andreas-garcia/)
- 📧 **Email**: garcia.andreas.1991@gmail.com
- 🐛 **Issues**: [Report bugs or suggest features](https://github.com/Andreas-Garcia/audiometa/issues)
- 💬 **Discussions**: [Join the conversation](https://github.com/Andreas-Garcia/audiometa/discussions)

## ⭐ Show Your Support

Open-source projects thrive with community support! Here's how you can help:

- ⭐ **Star repositories** you find useful - helps others discover them
- 🐛 **Report bugs** - your feedback makes projects better
- 💡 **Suggest features** - share your ideas and use cases
- 🤝 **Contribute code** - PRs are always welcome!
- 📝 **Improve docs** - help others understand and use the tools
- 💬 **Join discussions** - share experiences and help others
- 📢 **Spread the word** - tell others about projects you love

**Every bit of support helps build better tools for everyone!** 🙏

---

<div align="center">
  
  **Thanks for visiting! 🎵**
  
  [![Profile Views](https://komarev.com/ghpvc/?username=Andreas-Garcia&color=blueviolet&style=flat-square)](https://github.com/Andreas-Garcia)
  
</div>
