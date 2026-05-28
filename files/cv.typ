// --- GLOBAL PAGE SETUP ---
#set page(
  paper: "us-letter",
  margin: (x: 1.2cm, y: 1.2cm), // Slightly smaller margins to help fit one page
)

#set text(size: 9.5pt, fill: rgb("#111111"), spacing: 110%)
#set par(justify: true, leading: 0.5em)

// --- CUSTOM LAYOUT HELPERS ---
#let section-heading(title) = {
  v(0.8em, weak: true) // Reduced padding from 1.5em
  text(size: 11.5pt, weight: "bold", tracking: 0.5pt, fill: rgb("#1a365d"))[#title]
  v(-0.6em)
  line(length: 100%, stroke: 0.75pt + rgb("#cbd5e1"))
  v(0.4em)
}

#let cv-entry(
  title: "",
  skills: "",
  start-date: "",
  end-date: "",
  subtitle: "",
  sub-right-text: "",
  content
) = {
  block(width: 100%, breakable: false)[
    #strong(title)
    #if skills != "" [ #h(0.5em) #text(size: 8.5pt, fill: rgb("#4a5568"))[#skills] ]
    #h(1fr) #start-date — #end-date \
    #if subtitle != "" or sub-right-text != "" {
      emph(subtitle) + h(1fr) + emph(sub-right-text)
      v(0.1em)
    }
    #content
  ]
  v(0.2em)
}

// --- DOCUMENT CONTENT ---

// Header / Personal Details
#align(center)[
  #text(size: 20pt, weight: "bold")[Dmitrii Kovanikov] \
  #v(-0.2em)
  #text(size: 10.5pt, weight: "medium", fill: rgb("#4a5568"))[Senior Software Engineer] \
  #v(0.2em)
  #text(size: 8.5pt)[
    London, UK | 
    #link("mailto:chshersh@gmail.com")[chshersh\@gmail.com] | 
    #link("https://chshersh.com")[chshersh.com] | 
    #link("https://linkedin.com/in/chshersh")[linkedin.com/in/chshersh] | 
    #link("https://github.com/chshersh")[github.com/chshersh]
  ]
]

// --- EXPERIENCE SECTION ---
#section-heading("Experience")

#cv-entry(
  title: "Bloomberg",
  skills: "C++, OCaml, Python, TypeScript, Kafka, SQL",
  start-date: "May 2023",
  end-date: "Present",
  subtitle: "Senior Software Engineer",
  sub-right-text: "London, UK"
)[
  - Built and optimized high-throughput market data feed handlers for 40+ European exchanges (including Xetra and Eurex) and cryptocurrency venues; processed 1B+ daily messages across TCP/UDP multicast feeds and binary, JSON, XML, and CSV market data protocols.
  - Led the implementation of the EMDI refresh/recovery protocol for Xetra multicast feeds in modern C++; engineered deterministic state management for packet loss recovery, duplicate suppression, sequencing, and snapshot synchronization in latency-sensitive distributed systems.
  - Drove engineering excellence across a 150+ engineer department by designing and teaching advanced C++23 and Functional Programming courses; introduced modern C++ best practices around resource management, compile-time programming, performance analysis, and maintainable systems design.
]

#cv-entry(
  title: "Feeld",
  skills: "Haskell, CoffeeScript, Python, MongoDB, RabbitMQ, PostgreSQL, GCP",
  start-date: "Apr 2022",
  end-date: "Apr 2023",
  subtitle: "Senior Software Engineer",
  sub-right-text: "London, UK"
)[
  - Architecting & engineering a scalable backend for a popular dating app.
  - Fixed multi-year problems for paid users which increased the company's revenue and helped the CX team be more efficient.
  - Created an error-monitoring dashboard using MongoDB, PostgreSQL, BigQuery, and Excel which helped drive product development priorities.
  - Implemented rate-limiting component free of race conditions and contributed it to the upstream open-source dependency.
]

#cv-entry(
  title: "Standard Chartered",
  skills: "C++, Haskell, SQLite, Kubernetes, Ansible",
  start-date: "Dec 2019",
  end-date: "Apr 2022",
  subtitle: "Quantitative Developer",
  sub-right-text: "London, UK"
)[
  - Implementing a low-latency, high-throughput backend query engine.
  - Helped the company save \$8M/year by leading and finishing successfully the development of the trading regulations component.
  - Improved dev efficiency for the entire team by implementing content-addressable caching in a custom build tool.
]

#cv-entry(
  title: "Holmusk",
  skills: "Haskell, Node.js, PostgreSQL, MySql, AWS",
  start-date: "May 2018",
  end-date: "Nov 2019",
  subtitle: "Software Engineer",
  sub-right-text: "Singapore"
)[
  - Engineering backend and frontend for the Type 2 Diabetes management platform.
  - Designed & implemented the entire platform for Type 2 Diabetes clinical research.
  - Successfully redesigned the existing Type 2 Diabetes management platform to improve efficiency and dev velocity.
]

#cv-entry(
  title: "Serokell",
  skills: "Haskell, Python",
  start-date: "May 2016",
  end-date: "May 2018",
  subtitle: "Software Engineer",
  sub-right-text: "St. Petersburg, Russia"
)[
  - Developing distributed blockchain and cryptocurrency technologies.
  - Developed authorization part of a cryptocurrency to ensure a smooth launch.
  - Created the company website in 2 days after a consultant spent 3 months on it.
]

#cv-entry(
  title: "Yandex",
  skills: "Java",
  start-date: "Feb 2016",
  end-date: "May 2016",
  subtitle: "Metrics Intern",
  sub-right-text: "St. Petersburg, Russia"
)[]

#cv-entry(
  title: "JetBrains",
  skills: "Kotlin",
  start-date: "Jul 2015",
  end-date: "Sep 2015",
  subtitle: "Kotlin Compiler Intern",
  sub-right-text: "St. Petersburg, Russia"
)[]


// --- ACHIEVEMENTS SECTION ---
#section-heading("Achievements")

- Popular X account with *70K+ followers*, highly-engaged in C++ and tech trends discussions.
- Gave *12 talks* at various tech conferences and meet-ups.
- Solved a *highly ambiguous* problem "Paid subscriptions don't work for some people" in a complex project
- Created a Haskell course officially acknowledged by Haskell.org, with *45K+ views* on YouTube 
- Successfully finished rewrite of *300K+ LOC* Node.js project to Haskell with zero bugs in production


// --- EDUCATION SECTION ---
#section-heading("Education")

#cv-entry(
  title: "ITMO University",
  start-date: "2011",
  end-date: "2015",
  subtitle: "Bachelor in Computer Science & Applied Math",
  sub-right-text: "St. Petersburg, Russia"
)[]
