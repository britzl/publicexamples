![](images/logo.png)

# Public Defold Examples
This project contains several small examples for the [Defold](http://www.defold.com) engine. Most examples are created in response to questions on the [Defold forum](https://forum.defold.com).

## Live examples
See some of the examples live [at the demo site](http://britzl.github.io/publicexamples/):

[![](images/demo_site.png)](http://britzl.github.io/publicexamples/)

## How to try the examples yourself
Each example is located in a subfolder of the `examples` folder. Each example consists of a main collection with the same name as the folder it is located in:

![Naming convention of examples](images/naming_convention.png)

You can try the examples yourself using one of the following methods:

### Download and copy the files to an existing project
You can try the examples yourself by [downloading](https://github.com/britzl/publicexamples/archive/master.zip) all of the example files and copying them to a Defold project. It is recommended that you create an empty Defold project from the [dashboard](http://dashboard.defold.com/) and copy the files into that project (take care to not remove the .git folder!)

This approach is described in detail by forum user h3annawill in [this excellent video tutorial](https://forum.defold.com/t/how-to-explore-defold-examples-for-the-beginner/3013):

[![Video tutorial](images/video_tutorial.png)](https://forum.defold.com/t/how-to-explore-defold-examples-for-the-beginner/3013)

### Fork the project and change remote repo of an existing project
Another way to try the examples is to [fork the project](https://help.github.com/articles/fork-a-repo/) and then [change the remote repository](https://help.github.com/articles/changing-a-remote-s-url/) of an existing Defold project so that it points to your fork on GitHub. It is recommended that you create and use an empty Defold project from the [dashboard](http://dashboard.defold.com/). Once you've pointed your empty project to your fork you need to [pull the contents of your fork into the empty project](https://git-scm.com/docs/git-pull). The advantage of this solution is that it is easy to pull new examples and fixes from this project into your own fork. You can do all of this using a Git tool such as [GitHub for Desktop](https://desktop.github.com), [SourceTree](https://www.sourcetreeapp.com/) or [Git Kraken](https://www.gitkraken.com/) or from the command line:

	cd path/to/root/of/your/created/defold/project
	git remote set-url origin https://github.com/your_user_name_on_github_here/publicexamples.git
	git fetch
	git reset --hard origin/master

## License
The examples are released under the same [Terms and Conditions as the Defold editor and service itself](http://www.defold.com/about-terms/).

## Credits
Assets by [Kenney](http://www.kenney.nl)
