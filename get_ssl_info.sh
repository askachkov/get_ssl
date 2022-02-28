if [ -z "$1" ]; then
	echo "get_ssl_info URL"
else
	CVS=$1
	while IFS=, read -r field1
	do
	    URL=$(basename $field1)
		IPs=$(dig +short $URL)
		while IFS= read -r IP
		do
			if [ ! -f "/tmp/$URL.pem" ]; then
				openssl s_client -servername $URL -connect $IP:443 -ign_eof 2>&1 | openssl x509  > /tmp/$URL.pem
			fi
			SN=$(openssl x509 -noout -serial -in /tmp/$URL.pem | sed 's/.*serial=\(.*\)$/\1/')
            ISSUER=$(echo -n | openssl x509 -in /tmp/$URL.pem -text -noout | grep -i "Issuer: ")
            IM_CN=$(echo "$ISSUER" | sed 's/.*CN = \(.*\)$/\1/')
            IM_C=$(echo "$ISSUER" | sed 's/.*C = \([^,]*\).*$/\1/')
            IM_O=$(echo "$ISSUER" | sed 's/.*O = \([^,]*\).*$/\1/')
            echo -n "$URL;"
            echo -n "$SN;"
			echo -n "$IM_CN;"
			echo -n "$IM_C;"
			echo -n "$IM_O;"
			echo ""
		done < <(printf '%s\n' "$IPs")
		wait
	done < $CVS
	wait
fi
