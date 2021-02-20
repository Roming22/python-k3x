import os
from subprocess import CalledProcessError
from subprocess import run as sp_run

from pytest import fail, fixture


@fixture
def project_path():
    return os.path.abspath(os.getcwd())


@fixture
def run():
    def func(cmd):
        try:
            sp_run(cmd, capture_output=True, check=True, text=True)
        except CalledProcessError as ex:
            fail(
                f"""\nCMD: {" ".join(cmd)}\nSTDOUT: {ex.stdout}\nSTDERR: {ex.stderr}""",
                False,
            )
        except Exception as ex:
            fail(f"""CMD: {" ".join(cmd)}\nEXCEPTION: {ex}""")

    return func
