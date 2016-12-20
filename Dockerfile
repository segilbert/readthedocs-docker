FROM python:2

ENV APPDIR /www

# Prep the environment
RUN apt-get update && apt-get -y install \
  texlive-latex-recommended \
  texlive-fonts-recommended \
  texlive-latex-extra \
  doxygen \
  dvipng \
  graphviz \
  nginx \
  nano

# Install readthedocs (latest)
RUN mkdir $APPDIR
WORKDIR $APPDIR

# Pull Down latest verion
RUN mkdir -p tmp && \
    wget -q --no-check-certificate https://github.com/rtfd/readthedocs.org/archive/master.zip 

unzip /tmp/master.zip >/dev/null 2>/dev/null && \
mv readthedocs.org-master/* $APPDIR/readthedocs.org/.??* . && \
rmdir readthedocs.org-master

WORKDIR readthedocs.org

# Install the required Python packages
RUN pip install -r requirements.txt

# Install a higher version of requests to fix an SSL issue
RUN pip install requests==2.6.0

# Override the default settings
COPY ./files/local_settings.py ./readthedocs/settings/local_settings.py
COPY ./files/tasksrecommonmark.patch ./tasksrecommonmark.patch

# Patch tasks.py to use newer recommonmark
RUN patch ./readthedocs/projects/tasks.py < ./tasksrecommonmark.patch

# Deploy the database
RUN python ./manage.py migrate

# Create a super user
RUN echo "from django.contrib.auth.models import User; User.objects.create_superuser('admin', 'admin@localhost', 'admin')" | python ./manage.py shell

# Load test data
RUN python ./manage.py loaddata test_data

# Copy static files
RUN python ./manage.py collectstatic --noinput

# Install gunicorn web server
RUN pip install gunicorn
RUN pip install setproctitle

# Set up the gunicorn startup script
COPY ./files/gunicorn_start.sh ./gunicorn_start.sh
RUN chmod u+x ./gunicorn_start.sh

# Install supervisord
RUN pip install supervisor
ADD files/supervisord.conf /etc/supervisord.conf

VOLUME $APPDIR/readthedocs.org

ENV RTD_PRODUCTION_DOMAIN 'localhost:8000'

# Set up nginx
COPY ./files/readthedocs.nginx.conf /etc/nginx/sites-available/readthedocs
RUN ln -s /etc/nginx/sites-available/readthedocs /etc/nginx/sites-enabled/readthedocs

# Clean Up Apt

RUN apt-get autoremove -y

CMD ["supervisord"]
