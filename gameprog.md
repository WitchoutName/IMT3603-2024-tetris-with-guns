# Submission

## Team members:
1. Mateusz Tomasz Kaczmarek
2. Elias Eide Kjellman
3. Snorre Hareide Hansen
4. Ruben Singer
5. Henrik Guthormsen
6. Tomáš Foltyn

## Github repo: 
https://github.com/WitchoutName/IMT3603-2024-tetris-with-guns

## Video link: 
A video of the gameplay showing off the important parts of the game

## Group Discussions on the development process:

### Strengths and weaknesses of engine you used in your game

As the engine for our project we use Godot. This choice was made after holding a group vote. The other engine we considered was Unity, Unreal Engine was not considered as it is mainly used for 3D development, neither was implementing the game with SDL and C++.
Godot was recommended to us as a solid choice for 2D game development by the professor. We liked its free and Open Source nature, and some of us also heavily disagreed with the recent (canceled) actions made by the creators of the Unity engine. Most of us did not have much previous experience with game engines and were open to trying out Godot.
#### Strengths:
A big appeal of Godot is that it is entirely free and Open Source. Everyone can contribute to the development of the engine which has been steadily growing over the years, with even faster growth in recent times.
Godot is a very lightweight engine, being well under half a gigabyte. Compared to some other engines on the market, like for example the Unreal Engine, the size difference is very substantial. Its smaller size also means faster loading times. The projects made in Godot also take up minimal storage space. 
On the more technical side, all entities and objects in Godot are Nodes. Nodes can be arranged together in a scene tree and there work together to provide an experience. This allows for a very modular implementation of objects, most of them being in separate nodes. Node’s scripts can additionally derive from other scripts. All this combined makes a smooth and easy development process where nodes can be implemented separately and later combined together in a scene. 
Godot offers a functionality called “signals”. Signals can be emitted by a node to notify other listening nodes of anything. They allow parameter passage. Signals were simple to use and allowed for simple communication between different components of a scene. 
Programming of scripts in Godot can be done either in C# or the engine native GDScript. For our project we used GDScript as it was the language with the most resources online for Godot context and due to many of our member having no previous experience with C#. GDScript proved to be easy to learn and use. Syntactically it is really similar to Python and thus pretty straight forward. The language also provided a lot of functionalities that proved very useful due to it being made especially for the engine and thus having a deep integration with it. 
For our project we developed a 2D game, which Godot is very well suited for. While Godot’s tools provided for development of 3D games might be less attractive than its competitors, Godot allows for easy implementation of good 2D games. 
We also believe that Godot was overall quite easy to learn and understand. The UI, although a bit clunky sometimes, is easily understandable and less “intimidating” than in some other engines. 
Overall we believe that Godot was a good choice for our project and are happy with its use. 
#### Weaknesses:
During our time using Godot, we encountered a few issues. 

During development, we encountered an unusual issue where duplicate script files, such as player.gd, appeared in Godot. These "ghost files" caused conflicts like duplicate methods or calls being executed, leading to unpredictable behavior. Strangely, these duplicates were only visible in the Godot script editor and could not be found in the file explorer or project folder, making it impossible to directly edit or remove them.
This issue forced us to roll back to a previous version of the project to resolve the problem, as there was no way to identify or fix the ghost files within the editor. We suspect this may have been caused by improper file handling, such as renaming or moving files, or possibly a cache or metadata issue within Godot.

Because Godot 4 was released 1.5 years ago, a lot of the community content (videos, forum) for Godot is in Godot 3, making it a bit harder for us to find good community resources on Godot 4. Also when using AI like ChatGPT, it would often give suggestions for Godot 3,  unless we specifically asked for Godot 4. For example when making the map, many resources used the deprecated TileMap, instead of the new TileMapLayer. Godot also has a lot less resources in their asset library than for example Unity. 
Also has Godot the bad habit to crash unexpectedly leading sometimes to the minor loss of most recent changes. 


### How you controlled process and communication systems during development

We used Discord to communicate. There we had almost weekly meetings, checking in on the progress everybody made through the week, solving problems and discussing our goals for the next meetings. The text channels and calendar were used to communicate meetings and share smaller progresses, highlights or issues. The discord text channel was also used to hold votes about different choices we made throughout the project, like for example on the more general side the choice of our engine, or directly connected to the game choice around how the tower terminal should work. 

Miro was used for planning out the game. When we were first assigned groups at the start of the semester, we had a meeting where we brainstormed ideas and added them to a Miro board. This board was later used to look at for deciding which features, weapons and items we should add to the game. The notes on Miro ranged from general mechanics to silly item ideas.
Google Docs for collaborative writing. Towards the end of the project, we created a google document where we listed all the things we needed to finish, as well as optional things we wanted to do if we had the time. Then for making the actual submission markdown document at the very end, we created another google document where we collaboratively wrote down what we wanted to include, before using it to make the final markdown document.

#### Use of version control systems, ticket tracking, branching, version control
We used github as a version control system and branching. The ticket tracking happened mainly through Discord. Github issues were only used for the first couple of tasks and the “Playtest and Feedback” with another group. The tasks were mostly delegated during discord meetings.
When working we created our own branches for committing changes, it was then merged to main on the meeting or before the meeting. 




# Rubric:

## 
1. M - Mateusz Tomasz Kaczmarek
2. E - Elias Eide Kjellman
3. S - Snorre Hareide Hansen
4. R - Ruben Singer
5. H - Henrik Guthormsen
6. T - Tomáš Foltyn

| | # claim |Others| All	| Most | Half | Some | Touched |
|----|----|-|----|----|----|----|----|
| Networking	| 1 || 0 | 0 | 0 | 0 | N |
| Map | 1 || 0 | 0 | 0 | N | N |
| Guns | 2 || 0 | 0 | 1 | N | N |
| Tower | N || 0 | 1 | 1 | N | N |
| Hitboxes | N || 1 | 1 | 2 | N | N |
| Inventory | N || 1 | 1 | 2 | N | N |
| Item script | N || 1 | 1 | 2 | N | N |
| Items | N || 1 | 1 | 2 | N | N |
| Player movement | N || 1 | 1 | 2 | N | N |
| Player | N || 1 | 1 | 2 | N | N |
| Health system | N || 1 | 1 | 2 | N | N |
| Melee Weapons | N || 1 | 1 | 2 | N | N |
| Interaction system | N || 1 | 1 | 2 | N | N |
| HUD | N || 1 | 1 | 2 | N | N |
| Menu | N || 1 | 1 | 2 | N | N |
| Spawners | N || 1 | 1 | 2 | N | N |
| Animations | N || 1 | 1 | 2 | N | N |



