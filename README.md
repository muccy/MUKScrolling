MUKScrolling
===========
MUKScrolling is a simple, block-based, ARC-enabled, iOS 4+ library built to provide you some useful scrolling views.
It is composed by two main classes:
* `MUKRecyclingScrollView`, an `UIScrollView` subclass which implements some basic methods to recycle subviews like `UITableView` does.
* `MUKGridView`, a concrete `MUKRecyclingScrollView` subclass which implements the logic to display horizontal and vertical grids of cells (see examples: you can create thumbnails grid, pages carousels, ...).

There are other more complex solutions (different but, probabily better under some aspects) like [GMGridView], which acts more like `UITableView`, if you want.

Requirements
------------
* ARC enabled compiler
* Deployment target: iOS 5 or greater
* Base SDK: iOS 6 or greater
* Xcode 4.5 or greater

Installation
------------
*Thanks to [jverkoey iOS Framework]*.

#### Step 0: clone project from GitHub recursively, in order to get also submodules

    git clone --recursive git://github.com/muccy/MUKScrolling.git

#### Step 1: add MUKScrolling to your project
Drag or *Add To Files...* `MUKScrolling.xcodeproj` to your project.

<img src="http://i.imgur.com/MZZwt.png" />

Please remember not to create a copy of files while adding project: you only need a reference to it.

<img src="http://i.imgur.com/kXEJZ.png" />

Now add `MUKToolkit.xcodeproj` by choosing that project from `Submodules/MUKToolkit`. With this step you are adding `MUKObjectCache` dependencies. If your project already contains dependencies please take care to use updated libraries.

<img src="http://i.imgur.com/AQkuD.png" />

#### Step 2: make your project dependent
Click on your project and, then, your app target:

<img src="http://i.imgur.com/J10tA.png" />

Add dependency clicking on + button in *Target Dependencies* pane and choosing static library target (`MUKScrolling`) and its dependency (`MUKToolkit`):

<img src="http://i.imgur.com/XUAMK.png" />

Link your project clicking on + button in *Link binary with Libraries* pane and choosing static library product (`libMUKScrolling.a`). Link also submodule dependency (`libMUKToolkit.a`):

<img src="http://i.imgur.com/Cqjx5.png" />

#### Step 3: link required frameworks
You need to link those framework in order to support `MUKToolkit` dependency:

* `Foundation`
* `UIKit`
* `CoreGraphics`
* `Security`

To do so you only need to click on + button in *Link binary with Libraries* pane and you can choose them. Tipically you only need to add `Security`:

<img src="http://i.imgur.com/fTdEp.png" />

#### Step 4: load categories
In order to load every method in `MUKToolkit` dependency you need to insert `-ObjC` flag to `Other Linker Flags` in *Build Settings* of your project.

<img src="http://i.imgur.com/u9OUD.png" /> 


#### Step 5: import headers
You only need to write `#import <MUKScrolling/MUKScrolling.h>` when you need headers.
You can also import `MUKScrolling` headers in your `pch` file:

<img src="http://i.imgur.com/owsNo.png" />


Documentation
-------------
Build `MUKScrollingDocumentation` target in order to install documentation in Xcode.

*Requirement*: [appledoc] awesome project.

*TODO*: online documentation.



License
-------
Copyright (c) 2012, Marco Muccinelli
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright
notice, this list of conditions and the following disclaimer.
* Redistributions in binary form must reproduce the above copyright
notice, this list of conditions and the following disclaimer in the
documentation and/or other materials provided with the distribution.
* Neither the name of the <organization> nor the
names of its contributors may be used to endorse or promote products
derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL <COPYRIGHT HOLDER> BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


[GMGridView]: https://github.com/gmoledina/GMGridView
[jverkoey iOS Framework]: https://github.com/jverkoey/iOS-Framework
[appledoc]: https://github.com/tomaz/appledoc
