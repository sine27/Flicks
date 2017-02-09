# Project 1 - *Flicks*

**Flicks** is a movies app using the [The Movie Database API](http://docs.themoviedb.apiary.io/#).

Time spent: 

- **6** hours spent in Version 1.1
- **1** hours spent in Version 1.2
- **4** hours spent in Version 1.3
- **3** hours spent in Version 1.4

**14** hours spent in total


## User Stories

The following **required** functionality is complete:

- ☑️ User can view a list of movies currently playing in theaters from The Movie Database. 
- ☑️ Poster images are loaded using the UIImageView category in the AFNetworking library.
- ☑️ User sees a loading state while waiting for the movies API.
- ☑️ User can pull to refresh the movie list.

The following **optional** features are implemented:

- ☑️ User sees an error message when there's a networking error.
- ☑️ Movies are displayed using a CollectionView instead of a TableView.
- ☑️ User can search for a movie.
- ☑️ All images fade in as they are loading.
- ☑️ Customize the UI.

The following **additional** features are implemented:

- ☑️ Search "Not Found" notification
- ☑️ "No More Result" symbol

Please list two areas of the assignment you'd like to **discuss further with your peers** during the next class (examples include better ways to implement something, how to extend your app in certain ways, etc):

...

## Video Walkthrough 

Here's a walkthrough of implemented user stories:

version 1.1

<img src='https://github.com/sine27/Flicks/blob/master/demo/assign1-1.gif' title='tip calculation' width='270' alt='Video Walkthrough' />

version 1.2 search activated

<img src='https://github.com/sine27/Flicks/blob/master/demo/assign1-2search.gif' title='tip calculation' width='270' alt='Video Walkthrough' />

version 1.3 Collection view

<img src='https://github.com/sine27/Flicks/blob/master/demo/assign1-3collection.gif' title='tip calculation' width='270' alt='Video Walkthrough' />

version 1.4 "no more result" symbol & timeout notification and refresh enabled

<img src='https://github.com/sine27/Flicks/blob/master/demo/assign1-4timeout.gif' title='tip calculation' width='270' alt='Video Walkthrough' />

# Project 2 - *Flicks*

**Flicks** is a movies app using the [The Movie Database API](http://docs.themoviedb.apiary.io/#).

Time spent: 

- **7** hours spent in Version 2.1
- **3** hours spent in Version 2.2

**10** hours spent in total

## User Stories

The following **required** functionality is completed:

- ☑️ User can view movie details by tapping on a cell.
- ☑️ User can select from a tab bar for either **Now Playing** or **Top Rated** movies.
- ☑️ Customize the selection effect of the cell.

The following **optional** features are implemented:

- ☑️ For the large poster, load the low resolution image first and then switch to the high resolution image when complete.
- ☑️ Customize the navigation bar.

The following **additional** features are implemented:

- ☑️ enabled hide and show the detail with animation
- ☑️ scroll view on detail view
- ☑️ sort the movies by swiching filter keys
- ☑️ zooming image enabled

## Video Walkthrough 

Here's a walkthrough of implemented user stories:

version 2.1 detail view enabled with animation and custom navigation bar & filter (change by sorting key)

<img src='https://github.com/sine27/Flicks/blob/master/demo/assign2-1detail&filter.gif' title='tip calculation' width='270' alt='Video Walkthrough' />

version 2.2 tab view & zoom image

<img src='https://github.com/sine27/Flicks/blob/master/demo/assign2-2tabView.gif' title='tip calculation' width='270' alt='Video Walkthrough' />

## Notes

Assigning data is difficult. I should pay a lot attention on name of a key. Animation sometime conflicked with each other and make the view strange. Gesture may affect tableview and collectionview performance.

## License

    Copyright [2017] [Shayin Feng]

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
