FROM astrocrpublic.azurecr.io/runtime:3.0-8

# ============================================================
# dbt execution
# ============================================================
RUN python -m venv dbt_venv \
        && source dbt_venv/bin/activate \
        && pip install --no-cache-dir --upgrade dbt-core==1.7.1 \
          --trusted-host pypi.python.org \
          --trusted-host pypi.org \
          --trusted-host files.pythonhosted.org \
          --trusted-host pip.astronomer.io \
        && pip install --no-cache-dir --upgrade dbt-snowflake==1.7.0 \
          --trusted-host pypi.python.org \
          --trusted-host pypi.org \
          --trusted-host files.pythonhosted.org \
          --trusted-host pip.astronomer.io \
        && pip install --no-cache-dir setuptools \
          --trusted-host pypi.python.org \
          --trusted-host pypi.org \
          --trusted-host files.pythonhosted.org \
          --trusted-host pip.astronomer.io \
        && pip install --no-cache-dir --upgrade protobuf==4.25.3 \
          --trusted-host pypi.python.org \
          --trusted-host pypi.org \
          --trusted-host files.pythonhosted.org \
          --trusted-host pip.astronomer.io \
        && deactivate

USER root        
# ============================================================
# SQL Server ODBC driver
# ============================================================
RUN curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | tee /etc/apt/trusted.gpg.d/microsoft.asc

RUN curl -fsSL https://packages.microsoft.com/config/debian/11/prod.list > /etc/apt/sources.list.d/mssql-release.list

RUN apt-get update && ACCEPT_EULA=Y apt-get install -y msodbcsql17

# ============================================================
# Oracle Instant Client (thick mode)
# ============================================================
RUN apt-get update && apt-get install -y --no-install-recommends unzip \
 && ( apt-get install -y --no-install-recommends libaio1 \
      || ( apt-get install -y --no-install-recommends libaio1t64 \
           && ln -sf /usr/lib/x86_64-linux-gnu/libaio.so.1t64 \
                     /usr/lib/x86_64-linux-gnu/libaio.so.1 ) ) \
 && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /opt/oracle && cd /opt/oracle \
 && curl -fsSL -o ic.zip https://download.oracle.com/otn_software/linux/instantclient/instantclient-basiclite-linuxx64.zip \
 && unzip -q ic.zip \
 && rm -f ic.zip \
 && IC_DIR="$(find /opt/oracle -maxdepth 1 -type d -name 'instantclient_*' | head -1)" \
 && echo "Instant Client unpacked to: $IC_DIR" \
 && ln -sfn "$IC_DIR" /opt/oracle/instantclient \
 && { [ -e /opt/oracle/instantclient/libclntsh.so ] \
      || ln -s "$(ls /opt/oracle/instantclient/libclntsh.so.* | head -1)" \
               /opt/oracle/instantclient/libclntsh.so ; } \
 && echo "/opt/oracle/instantclient" > /etc/ld.so.conf.d/oracle-instantclient.conf \
 && ldconfig \
 && ls -l /opt/oracle/instantclient/libclntsh.so

ENV LD_LIBRARY_PATH="/opt/oracle/instantclient:${LD_LIBRARY_PATH:-}"

USER astro