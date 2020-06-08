#!/bin/bash
   sudo amazon-linux-extras install -y nginx1
   sudo systemctl start nginx
   sudo systemctl enable nginx

   mkdir /root/scripts

   << EOF > /root/scripts/logs_to_s3.sh
   #!/bin/bash
   bucket_name='logz-bucket-demo'
   path_to_file='logs';
   filename='error.log';

   if [ -s /var/log/nginx/error.log ]
   then
           #move error.log to s3 bucket
           aws s3 cp /var/log/nginx/error.log s3://$bucket_name/$path_to_file/$filename

           #make error.log empty
           > /var/log/nginx/error.log
   else
           echo "File is empty"
   fi
   EOF

   chmod u+x /root/scripts/logs_to_s3.sh
   crontab<<EOF
   0 8,12,16,20,0 * * * /root/scripts/logs-to-s3.sh
   EOF