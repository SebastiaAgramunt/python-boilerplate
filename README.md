# Python CPP Boilerplate


## Compile and install the package

Create a new package

```bash
rm -rf .venv
python3 -m venv .venv
.venv/bin/python -m pip install --upgrade pip
```

Then compile C++ bindings and install with pip

```bash
.venv/bin/python -m pip install .
```

## Run an example

To check that this is working try importing the package and running a script

```bash
.venv/bin/python -c "import package_example"
.venv/bin/python scripts/example.py
```

## Tesing & Linting

Run tests

```bash
.venv/bin/python -m pip install -e ".[test]"
.venv/bin/pytest -v

.venv/bin/ruff format .
.venv/bin/mypy src
```

## Build wheels

Locally you can build the wheels with

```bash
./scripts/build_wheel.sh
```

If you are in MacOS they will be placed in `dist`. In Linux they will be repaired and placed in `wheelhouse`. In my M4-MacOS the wheel will be

```bash
dist/package_example-0.0.1-cp313-cp313-macosx_26_0_arm64.whl
```

Optionally, the Linux version can be compiled also in MacOS through a Docker container: build and run the docker image first and once in the container run the build

```bash
TASK=build_image ./Docker/build-run.sh
TASK=run_image ./Docker/build-run.sh
./scripts/build_wheel.sh
```

In my system it creates the wheel in `dist`

```bash
dist/package_example-0.0.1-cp313-cp313-linux_aarch64.whl
```

## CI-CD for testing and wheel publishing

The software is tested on GitHub Actions for python versions `3.10-3.13`, architectures `x86` and `arm64` and on `ubuntu`, `macos` and `windows` operating systems. On each push in a branch the actions in `.github/workflows/build-wheels.yml` is kicked off. This action tests and publishes the wheel internally.

To publish the wheels just tag the release, go to master branch and check the version in `__version__` variable of `setup.py`. E.g. for the initial commit the version is `0.0.1`. Then we would run

```bash
VERSION=0.0.1
git tag -a v${VERSION} -m "v${VERSION}"
git push origin v${VERSION}
```
