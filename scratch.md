prompts

Delete commit.txt. Create a commit summary for all new and updated resources since the last commit. Then Save the new summary to commit.txt

for file in $(ls *.zip); do
unzip "$file"
done

# docker exec -it my-postgres psql -U postgres -c "CREATE USER mylegos_admin WITH PASSWORD 'pass.123'";

docker exec -it my-postgres psql -U postgres -c "CREATE DATABASE mylegos2 OWNER mylegos_admin";

# docker exec -it my-postgres psql -U postgres -c "GRANT ALL PRIVILEGES ON DATABASE mylegos2 TO mylegos_admin";

# docker exec -it my-postgres psql -U postgres -c "GRANT ALL PRIVILEGES ON SCHEMA public TO mylegos_admin";

docker exec -it my-postgres psql -U mylegos_admin -d mylegos2

docker exec -it my-postgres psql -U mylegos_admin -d mylegos2 -f /tmp/lego-db/init_db.sql

curl -X GET --header 'Accept: application/json' --header 'Authorization: key 1df22b3ce181c7eda9b620e2b28ab5d3' 'https://rebrickable.com/api/v3/users/b46bec01a819d3e44480fa74f3bdfb18e44881dbb22e9bd9dd708916e57e3910/partlists/' --output data/user/partlists.json

curl -X GET --header 'Accept: application/json' --header 'Authorization: key 1df22b3ce181c7eda9b620e2b28ab5d3' 'https://rebrickable.com/api/v3/users/b46bec01a819d3e44480fa74f3bdfb18e44881dbb22e9bd9dd708916e57e3910/partlists/793706/' --output data/user/partlists-793706.json

curl -X GET --header 'Accept: application/json' --header 'Authorization: key 1df22b3ce181c7eda9b620e2b28ab5d3' 'https://rebrickable.com/api/v3/users/b46bec01a819d3e44480fa74f3bdfb18e44881dbb22e9bd9dd708916e57e3910/partlists/793706/parts/' --output data/user/partlists-793706.json

function fetch() {
local id="$1"
CMD=$(cat << EOL
curl -X GET --header 'Accept: application/json' --header 'Authorization: key 1df22b3ce181c7eda9b620e2b28ab5d3' 'https://rebrickable.com/api/v3/users/b46bec01a819d3e44480fa74f3bdfb18e44881dbb22e9bd9dd708916e57e3910/partlists/${id}/parts/' --output data/user/partlists-${id}.json
sleep 1
npx prettier --write data/user/partlists-${id}.json
EOL
)
eval "$CMD"
}

for legoid in $(cat data/user/partlists.json | jq -r '.results[].id'); do
fetch "$legoid"
sleep 3
done
