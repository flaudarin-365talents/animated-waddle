# Debian 11 - current "stable" release on November 17th, 2021
FROM buildpack-deps:focal

# Ensures local python is preferred over distribution python
ENV PATH /usr/local/bin:$PATH

# http://bugs.python.org/issue19846
# > At the moment, setting "LANG=C" on a Linux system *fundamentally breaks Python 3*, and that's not OK.
ENV LANG C.UTF-8


# if this is called "PIP_VERSION", pip explodes with "ValueError: invalid truth value '<VERSION>'"
ENV PYTHON_PIP_VERSION 21.3.1
# https://github.com/docker-library/python/issues/365
ENV PYTHON_SETUPTOOLS_VERSION 57.5.0
# https://github.com/pypa/get-pip
ENV PYTHON_GET_PIP_URL https://github.com/pypa/get-pip/raw/3cb8888cc2869620f57d5d2da64da38f516078c7/public/get-pip.py
ENV PYTHON_GET_PIP_SHA256 c518250e91a70d7b20cceb15272209a4ded2a0c263ae5776f129e0d9b5674309

ENV POETRY_PATH /root/.poetry/bin
ENV POETRY_CACHE_PATH /root/.cache/pypoetry/

# Adds (in advance) poetry to the path
ENV PATH $POETRY_PATH:$PATH


# ======================== C O M P I L A T I O N   O F   P Y T H O N   3 . 6 . 9 ========================


RUN set -ex \
    && wget -O python.tar.xz "https://www.python.org/ftp/python/3.6.9/Python-3.6.9.tar.xz" \
    && mkdir -p /usr/src/python \
    && tar -xJC /usr/src/python --strip-components=1 -f python.tar.xz \
    && rm python.tar.xz \
    && cd /usr/src/python \
    && gnuArch="$(dpkg-architecture --query DEB_BUILD_GNU_TYPE)" \
    && ./configure \
    --build="$gnuArch" \
    --enable-loadable-sqlite-extensions \
    --enable-optimizations \
    --enable-option-checking=fatal \
    --enable-shared \
    --with-system-expat \
    --with-system-ffi \
    --without-ensurepip \
    && make install \
    && rm -rf /usr/src/python \
    \
    && find /usr/local -depth \
    \( \
    \( -type d -a \( -name test -o -name tests -o -name idle_test \) \) \
    -o \( -type f -a \( -name '*.pyc' -o -name '*.pyo' -o -name '*.a' \) \) \
    -o \( -type f -a -name 'wininst-*.exe' \) \
    \) -exec rm -rf '{}' + \
    \
    && ldconfig \
    && cd /usr/local/bin \
    && ln -s idle3 idle \
    && ln -s pydoc3 pydoc \
    && ln -s python3 python \
    && ln -s python3-config python-config \
    \
    # =========================== I N S T A L L A T I O N   O F   P Y P I ============================
    && set -ex; \
    \
    # Downloads get-pip and installs pip
    wget -O get-pip.py "$PYTHON_GET_PIP_URL"; \
    echo "$PYTHON_GET_PIP_SHA256 *get-pip.py" | sha256sum --check --strict -; \
    \
    python get-pip.py \
    --disable-pip-version-check \
    --no-cache-dir \
    "pip==$PYTHON_PIP_VERSION" \
    "setuptools==$PYTHON_SETUPTOOLS_VERSION" \
    ; \
    pip --version; \
    \
    find /usr/local -depth \
    \( \
    \( -type d -a \( -name test -o -name tests -o -name idle_test \) \) \
    -o \
    \( -type f -a \( -name '*.pyc' -o -name '*.pyo' \) \) \
    \) -exec rm -rf '{}' +; \
    rm -f get-pip.py \
    # Updates pip and setuptools to the latest versions
    && python -m pip install -U pip setuptools \
    \
    # ========================= I N S T A L L A T I O N   O F   P O E T R Y ==========================
    && curl -sSL https://raw.githubusercontent.com/python-poetry/poetry/master/get-poetry.py | python - 

# Working directory
RUN mkdir /working_dir /root/data-models /root/nltk_data

WORKDIR /working_dir

CMD bash