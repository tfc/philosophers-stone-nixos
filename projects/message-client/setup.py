from setuptools import setup, find_packages

setup(
    name='message-client',
    packages=find_packages(),
    install_requires=[],
    entry_points = {
        'console_scripts': [
            'message-cli = messagedb.client:main',
            'message-webclient = messagedb.webserver:main'
        ]
    }
)
