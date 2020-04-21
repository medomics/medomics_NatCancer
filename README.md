# MEDomics - Nature Cancer Study

This repository provides the framework to reproduce the main learning experiments of the MEDomics manuscript submitted to <em>Nature Cancer</em> in April 2020. Improvements from contributors are expected over time and will be identified via specific commit checkpoints. The exact results produced by this framework may eventually slightly differ from the original ones found in our study over the different checkpoints. 

## Prerequisites
* We use [Conda](https://docs.conda.io) as our package manager.
* We require Python 3.7+

## Installing

```
git clone git@github.com:medomics/medomics_NatCancer.git
cd medomics_NatCancer
conda env create -f medomics_NatCancer.yml
conda activate medomics_NatCancer
```

## Using this repository

This repository is subdivided into three main high-level experiments of our study:
* Experiment1_KM: section used to reproduce the test experiments of current Figure 4 of the manuscript. 
* Experiment2_ML: section used to reproduce the test experiments of current Figure 5 of the manuscript.
* Experiment3_NLP: section used to reproduce the test experiments of current Figure 6 of the manuscript.

Please follow the instructions in the README file of each section. 

## Contributing to this repository

We would love to receive feedback to improve the learning experiments of this repository. To contribute, please follow these steps:

1. Fork this repository.
2. Create a branch: `git checkout -b <branch_name>`.
3. Make your changes and commit them: `git commit -m '<commit_message>'`
4. Push to the original branch: `git push origin <project_name>/<location>`
5. Create the pull request.

Alternatively see the GitHub documentation on [creating a pull request](https://help.github.com/en/github/collaborating-with-issues-and-pull-requests/creating-a-pull-request).

## Contributors

Thanks to the following people who have contributed to this repository:

* [Martin Vallières](https://github.com/mvallieres)
* [Jorge Barrios](https://github.com/numeroj)
* [Taman Upadhaya](https://github.com/TmnGitHub)

## Contact

For any scientific inquiries about this repository, please contact <medomics.info@gmail.com>.

## License

This project uses the following license: [GNU General Public License v3.0](https://www.gnu.org/licenses/gpl-3.0.en.html).