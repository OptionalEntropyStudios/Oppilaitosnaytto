using Godot;
using System;
using MySql.Data;
using MySql.Data.MySqlClient;
using Org.BouncyCastle.Security;
using Mysqlx.Crud;
using System.Web;
using System.Diagnostics;
using System.Transactions;
using System.Globalization;
public partial class mySqlTestConneciton : Node
{
	MySqlConnection connection;
	string connectionString = "SERVER=localhost;PORT=3306;DATABASE=peli_tietokanta;UID=root;PASSWORD=";


	public bool UsernameExists(string userName)
	{
		string query = $"SELECT * FROM player WHERE username = @username";
        bool exists = false;
        using (connection = new MySqlConnection(connectionString))
        {
            connection.Open();
            MySqlCommand command = connection.CreateCommand();
            command.CommandText = query;
            command.Parameters.Add(new MySqlParameter("@username", userName));
            MySqlDataReader reader = command.ExecuteReader();
            if (reader.HasRows)
            {
                
                exists = true;
            }
        }
        return exists;
        
    }

    public void RegisterUser(string userName)
    {
        using (connection = new MySqlConnection(connectionString))
        {
            connection.Open();
            string query = $"INSERT INTO player (username, credits, accuracy, destroyedRobots) VALUES (@username, 100, 100, 0)";
            MySqlCommand command = connection.CreateCommand();
            command.CommandText = query;
            command.Parameters.Add(new MySqlParameter("@username", userName));
            command.ExecuteNonQuery();
        }
    }

    //Check if the specified user own the specififed gun: pistol, smg or shotgun.
    //returns true, if there is an instance id with teh user's username and weapontype specified.
    public bool isOwned(string owner, string gunType)
    {
        string weaponInstanceID = owner + gunType;
        string query = $"SELECT * FROM weaponInstance WHERE instanceID = '{weaponInstanceID}'";
        bool owned = false;
        using (connection = new MySqlConnection(connectionString))
        {
            connection.Open();
            MySqlCommand command = connection.CreateCommand();
            command.CommandText = query;
            MySqlDataReader reader = command.ExecuteReader();
            if (reader.HasRows)
            {
                owned = true;
            }
        }
        return owned;
    }

    //Checks for any entries into the weaponupgrade table referencing the owned weapon.
    //Returns true, if the gun has any upgrades on it
    public bool HasUpgrades(string owner, string gunType)
    {
        string weaponInstanceID = owner + gunType;
        string query = $"SELECT * FROM weaponupgrade WHERE weaponinstanceID = '{weaponInstanceID}'";
        connection = new MySqlConnection(connectionString);
        connection.Open();
        MySqlCommand command = connection.CreateCommand();
        command.CommandText = query;
        MySqlDataReader reader = command.ExecuteReader();
        if (reader.HasRows)
        {
            reader.Close();
            connection.Close();
            return true;
        }
        else
        {
            reader.Close();
            connection.Close();
            return false;
        }
    }
    //Add lvl 1 upgrades for bulletdamage, firerate, capacity and reloadspeed to an owned weapon.
    public void AddBaseUpgrades(string owner, string gunType)
    {

        string weapontype = getWeaponAbbreviation(gunType);

        string weaponInstanceID = owner + gunType; //The "owned" gun's id, which is just username + guntype
        
        string query = $"INSERT INTO weaponupgrade " +
            $"(weaponinstanceid, upgradeid, upgradetype, upgradeprice, upgradelevel) VALUES ";

        //Each weaponupgrade has a unique integer id to differentiate them
        //bulletDamage = 1
        //firerate = 2
        //magazineSize = 3
        //reloadSpeed = 4

        //Create a query for each upgrade and set it's level to 1
        for (int i = 1; i <= 4; i++) {
            string upgradeID = owner + weapontype + i; //for example optionalentropypl1 or optionalentropysg3
            query += $"('{weaponInstanceID}', '{upgradeID}', '{i}', 100, 1)";
            if(i<4)
            {
                query += ",";
            }
        }
        using (connection = new MySqlConnection(connectionString))
        {
            connection.Open();
            MySqlCommand command = connection.CreateCommand();
            command.CommandText = query;
            command.ExecuteNonQuery();
        }
    }

    string getWeaponAbbreviation(string gunName)
    {
        if (gunName == "pistol")
        {
            return "pl";
        }
        else if (gunName == "smg")
        {
            return "sg";
        }
        else
        {
            return "sn";
        }
    }
    public int GetWeaponUpgradeLvl(string owner, string gunType , int upgradeType)
    {
        string weapontype = getWeaponAbbreviation(gunType);

        string targetUpgradeID = owner + weapontype + upgradeType.ToString();
        string upgradeLvlQuery = $"SELECT upgradelevel FROM weaponupgrade WHERE upgradeID = '{targetUpgradeID}'";
        int level = 1;
        using (connection = new MySqlConnection(connectionString))
        {
            connection.Open();
            MySqlCommand command = connection.CreateCommand();
            command.CommandText = upgradeLvlQuery;
            MySqlDataReader reader = command.ExecuteReader();
            if (reader.HasRows)
            {
                while (reader.Read())
                {
                    level = reader.GetInt32("upgradeLevel");
                }
            }
        }
        return level;
    }
    public int getUserCredits(string userName)
    {
        int creditsAmount = 0;
        string query = $"SELECT credits FROM player WHERE username = '{userName}'";
        using (connection = new MySqlConnection(connectionString))
        {
            connection.Open();
            MySqlCommand command = connection.CreateCommand();
            command.CommandText = query;
            MySqlDataReader reader = command.ExecuteReader();
            if (reader.HasRows)
            {
                while (reader.Read())
                {
                    creditsAmount = reader.GetInt32("credits");
                }

            }
        }
        return creditsAmount;
    }

    public int GetWeaponPrice(string weaponType)
    {
        string query = $"SELECT purchaseprice from weapon where weapontype = '{weaponType}'";
        int price = 9999;
        using (connection = new MySqlConnection(connectionString))
        {
            connection.Open();
            MySqlCommand command = connection.CreateCommand();
            command.CommandText = query;
            MySqlDataReader reader = command.ExecuteReader();
            
            if (reader.HasRows)
            {
                while (reader.Read())
                {
                    price = reader.GetInt32("purchaseprice");
                }
            }
        }
        return price;
    }

    public void updateUserCredits(string username, int credits)
    {
        string awardQuery = $"UPDATE player SET credits = {credits} WHERE username = '{username}'";
        using (connection = new MySqlConnection(connectionString))
        {
            connection.Open();
            MySqlCommand command = connection.CreateCommand();
            command.CommandText = awardQuery;
            command.ExecuteNonQuery();
        }
    }

    public string GetPlayerAverageAccuracy(string username)
    {
        //If the player doesn't have any run entries, there will be no data, so default is 100%
        string accuracyQuery = $"SELECT IFNULL(AVG(gunAccuracy),100) FROM defencerun WHERE player = '{username}'";
        double result = 0.0;

        using (connection = new MySqlConnection(connectionString))
        {
            connection.Open();
            MySqlCommand command = connection.CreateCommand();
            command.CommandText = accuracyQuery;
            //string result = command.ExecuteScalar().ToString();
            //string formattedResult = result.ToString("0.00");
            result = Convert.ToDouble(command.ExecuteScalar());
        }
        
        return result.ToString("0.00");
    }

    public void UpdatePlayerAccuracy(string username)
    {
        float averageAccuracy = GetPlayerAverageAccuracy(username).ToFloat();
        string formattedAvgAccuracy = averageAccuracy.ToString(CultureInfo.InvariantCulture); //Gotta format it to not have comma as decimal point
        string updateAccuracyQuery = $"UPDATE player SET accuracy = {formattedAvgAccuracy} WHERE username = '{username}'";
        using (connection = new MySqlConnection(connectionString))
        {
            connection.Open();
            MySqlCommand command = connection.CreateCommand();
            command.CommandText = updateAccuracyQuery;
            command.ExecuteNonQuery();
        }
    }
    public bool CanBuyGun(string username, string gunType)
    {
        int credits = getUserCredits(username);
        int weaponPrice = GetWeaponPrice(gunType);
        if (credits >= weaponPrice)
        {
            return true;
        }
        else
        {
            return false;
        }
    }

    //Create a new weaponinstance for the user, and remove the weapon price from the user's credits.
    public void BuyGun(string username, string gunType)
    {

        int credits = getUserCredits(username); //get the user's credits
        int weaponPrice = GetWeaponPrice(gunType); //get the price of the weapon
        int newCredits = credits - weaponPrice; //substract gun price from credits
        string instanceID = username + gunType; //create the id for the weapon

        //query to create the "ownership" for the gun
        string weaponInstanceQuery = "INSERT INTO weaponInstance (weaponowner, weapontype, destroyedrobots, instanceid, weaponname) " +
            $"VALUES ('{username}', '{gunType}', 0, '{instanceID}', '{gunType}')";
        //query to update usercredits
        string playerQuery = $"UPDATE player SET credits = {newCredits} WHERE username = '{username}'";
        using (connection = new MySqlConnection(connectionString))
        {
            connection.Open();
            MySqlCommand command = connection.CreateCommand();

            command.CommandText = weaponInstanceQuery;
            command.ExecuteNonQuery();

            command.CommandText = playerQuery;
            command.ExecuteNonQuery();
        }

        //After creating gun ownership, gotta add lvl 1 upgrades
        AddBaseUpgrades(username, gunType);
    }


    public string GetWeaponName(string username, string weaponType)
    {
        string weaponID = username + weaponType;
        //If the weapon is not named yet, get just the type
        string weaponNameQuery = $"SELECT IFNULL(weaponname, weapontype) FROM weaponinstance WHERE instanceID = '{weaponID}'";
        string weaponName = "";
        using (connection = new MySqlConnection(connectionString))
        {
            connection.Open();
            MySqlCommand command = connection.CreateCommand();
            command.CommandText = weaponNameQuery;
            weaponName = Convert.ToString(command.ExecuteScalar());
        }
        return weaponName;
    }

    public void ChangeWeaponName(string username, string weaponType, string newName)
    {
        string weaponID = username + weaponType;
        string changeNameQuery = $"UPDATE weaponinstance SET weaponname = @newname WHERE instanceID = '{weaponID}'";
        using (connection = new MySqlConnection(connectionString))
        {
            connection.Open();
            MySqlCommand command = connection.CreateCommand();
            command.CommandText = changeNameQuery;
            //No sql injections thank you :)
            command.Parameters.Add(new MySqlParameter("@newname", newName));
            command.ExecuteNonQuery();
        }
    }
    //Each weaponupgrade has a unique integer id to differentiate them
    //bulletDamage = 1
    //firerate = 2
    //magazineSize = 3
    //reloadSpeed = 4
    public bool CanBuyUpgrade(string username, string gunType, int upgradeID)
    {
        int credits = getUserCredits(username);
        string weaponAbbreviation = getWeaponAbbreviation(gunType);
        string upgradeInstanceID = username + weaponAbbreviation + upgradeID.ToString();
        int upgradePrice = GetUpgradePrice(upgradeInstanceID);
        if (credits >= upgradePrice)
        {
            return true;
        }
        else
        {
            return false;
        }
    }

    private void BuyUpgrade(string username, string gunType, int upgradeID)
    {
        int credits = getUserCredits(username);
        string weaponabbreviation = getWeaponAbbreviation(gunType);
        string upgradeInstanceID = username + weaponabbreviation + upgradeID.ToString();
        int currentUpgradeLevel = GetWeaponUpgradeLvl(username, gunType, upgradeID);
        int upgradePrice = GetUpgradePrice(upgradeInstanceID);
        string purchaseQuery = $"UPDATE weaponupgrade SET upgradelevel = {currentUpgradeLevel += 1}, upgradeprice = {upgradePrice + 100} WHERE upgradeid = '{upgradeInstanceID}'";
        using (connection = new MySqlConnection(connectionString))
        {
            connection.Open();
            MySqlCommand command = connection.CreateCommand();
            command.CommandText = purchaseQuery;
            command.ExecuteNonQuery();
            string removeCreditsQuery = $"UPDATE player SET credits = {credits - upgradePrice} WHERE username = '{username}'";
            command.CommandText = removeCreditsQuery;
            command.ExecuteNonQuery();
        }
    }
    public int GetUpgradePrice(string upgradeID)
    {
        string query = $"SELECT upgradePrice from weaponupgrade where upgradeId = '{upgradeID}'";
        int price = 9999;
        using (connection = new MySqlConnection(connectionString))
        {
            connection.Open();
            MySqlCommand command = connection.CreateCommand();
            command.CommandText = query;
            MySqlDataReader reader = command.ExecuteReader();
            
            if (reader.HasRows)
            {
                while (reader.Read())
                {
                    price = reader.GetInt32("upgradePrice");
                }
            }
        }
        return price;
    }

    public int getOwnedEquipmentAmount(string username, string equipmentType)
    {
        string equipmentQuery = $"SELECT equipmentamount FROM equipmentinstance WHERE equipmentOwner = '{username}' AND equipmentType = '{equipmentType}'";
        int ownedAmount = 0;
        using (connection = new MySqlConnection(connectionString))
        {
            connection.Open();
            MySqlCommand command = connection.CreateCommand();
            command.CommandText = equipmentQuery;
            MySqlDataReader reader = command.ExecuteReader();
            
            if (reader.HasRows)
            {
                while (reader.Read())
                {
                    ownedAmount = reader.GetInt32("equipmentAmount");
                }
            }
        }
        return ownedAmount;
    }

    public void updateOwnedEquipmentAmount(string username, string equipmentType, int ownedAmount)
    {
        string instanceID = username + equipmentType;
        string updateEquipmentQuery = $"UPDATE equipmentinstance SET equipmentAmount = {ownedAmount} WHERE instanceID = '{instanceID}'";
        using (connection = new MySqlConnection(connectionString))
        {
            connection.Open();
            MySqlCommand command = connection.CreateCommand();
            command.CommandText = updateEquipmentQuery;
            command.ExecuteNonQuery();
        }
    }

    public bool canBuyEquipment(string username, string equipmentType)
    {
        int usercredits = getUserCredits(username);
        int equipmentPrice = getEquipmentPrice(equipmentType);
        if (usercredits >= equipmentPrice)
        {
            return true;
        }
        return false;
    }

    public void BuyOneEquipment(string username, string equipmentType)
    {
        int usercredits = getUserCredits(username);
        int equipmentPrice = getEquipmentPrice(equipmentType);
        int creditsAfterPurchase = usercredits - equipmentPrice;
        if (EquipmentRegisteredToUser(username, equipmentType))
        {
            int ownedAmount = getOwnedEquipmentAmount(username, equipmentType);
            ownedAmount += 1;
            updateOwnedEquipmentAmount(username, equipmentType, ownedAmount);
        }
        else
        {   
            CreateNewEquipmentInstance(username, equipmentType, 1);
        }
        string updateCreditsQuery = $"UPDATE player SET credits = {creditsAfterPurchase} WHERE username = '{username}'";
        using (connection = new MySqlConnection(connectionString))
        {
            connection.Open();
            MySqlCommand command = connection.CreateCommand();
            command.CommandText = updateCreditsQuery;
            command.ExecuteNonQuery();
        }
    }

    public bool EquipmentRegisteredToUser(string username, string equipmentType)
    {
        string equipmentInstanceID = username + equipmentType;
        bool isRegistered = false;
        string equipmentQuery = $"SELECT * FROM equipmentInstance WHERE instanceid = '{equipmentInstanceID}'";
        using (connection = new MySqlConnection(connectionString))
        {
            connection.Open();
            MySqlCommand command = connection.CreateCommand();
            command.CommandText = equipmentQuery;
            MySqlDataReader reader = command.ExecuteReader();
            if (reader.HasRows)
            {
                isRegistered = true;
            }
        }
        return isRegistered;
    }

    public void CreateNewEquipmentInstance(string username, string equipmentType, int equipmentAmount)
    {
        string equipmentInstanceID = username + equipmentType;
        string createEquipmentQuery = $"INSERT INTO equipmentInstance (equipmentOwner, equipmentType, equipmentAmount, instanceID) VALUES ('{username}', '{equipmentType}', {equipmentAmount}, '{equipmentInstanceID}')";
        using (connection = new MySqlConnection(connectionString))
        {
            connection.Open();
            MySqlCommand command = connection.CreateCommand();
            command.CommandText = createEquipmentQuery;
            command.ExecuteNonQuery();
        }
    }
    public int getEquipmentPrice(string equipmentType)
    {   
        int price = 9999;
        string priceQuery = $"SELECT equipmentPrice FROM equipment WHERE equipmentType = '{equipmentType}'";
        using (connection = new MySqlConnection(connectionString))
        {
            connection.Open();
            MySqlCommand command = connection.CreateCommand();
            command.CommandText = priceQuery;
            MySqlDataReader reader = command.ExecuteReader();
            
            if (reader.HasRows)
            {
                while (reader.Read())
                {
                    price = reader.GetInt32("equipmentPrice");
                }
            }
        }
        return price;
    }

    public int GetRobotsDestroyedByWeapon(string weaponID)
    {
        int robotsDestroyed = 0;
        string robotsDestroyedQuery = $"SELECT destroyedRobots FROM weaponinstance WHERE instanceID = '{weaponID}'";
        using (connection = new MySqlConnection(connectionString))
        {
            connection.Open();
            MySqlCommand command = connection.CreateCommand();
            command.CommandText = robotsDestroyedQuery;
            MySqlDataReader reader = command.ExecuteReader();
            
            if (reader.HasRows)
            {
                while (reader.Read())
                {
                    robotsDestroyed = reader.GetInt32("destroyedRobots");
                }
            }
        }
        return robotsDestroyed;
    }

    public void UpdateWeaponDestroyedRobotsAmount(string username, string weaponType, int amount)
    {
        string weaponID = username + weaponType;
        int recordedDestructionAmount = GetRobotsDestroyedByWeapon(weaponID);
        int updatedAmount = amount + recordedDestructionAmount;
        string updateDestructionAmountQuery = $"UPDATE weaponinstance SET destroyedRobots = {updatedAmount} WHERE instanceID = '{weaponID}'";
        using (connection = new MySqlConnection(connectionString))
        {
            connection.Open();
            MySqlCommand command = connection.CreateCommand();
            command.CommandText = updateDestructionAmountQuery;
            command.ExecuteNonQuery();
        }
    }
    
    public void AddNewRunEntry(string username, int survivedWaves, int points, float accuracy)
    {
        //Each run id is username fllowed by the current year without the "prefix" 20 + month + date and then the current time in 2359 format.
        DateTime currentDate = DateTime.Now;
        string runYear = (currentDate.Year % 100).ToString(); //Get the end of the year: 25 for 2025 etc
        string runMonth = currentDate.Month.ToString("D2");
        string runDay = currentDate.Day.ToString("D2");
        string runTime = currentDate.ToString("HHmm");
        string runID = username + runYear + runMonth + runDay + runTime; //IDs are formated ie. optionalentropy2504101738
        string formattedAccuracy = accuracy.ToString(CultureInfo.InvariantCulture); //C# formats floats with a , separator instead of a . separator - it needs to be formatted to be passed into MySQL
        string runQuery = $"INSERT INTO defencerun(survivedrounds, gunaccuracy, points, player, runid) VALUES" +
            $"({survivedWaves}, {formattedAccuracy}, {points}, '{username}', '{runID}')";
        using (connection = new MySqlConnection(connectionString))
        {
            connection.Open();
            MySqlCommand command = connection.CreateCommand();
            command.CommandText = runQuery;
            command.ExecuteNonQuery();
        }
    }

    public string GetTop10Runs()
    {
        string rankingText = "";
        string runQuery = "SELECT survivedrounds, gunaccuracy, points, player FROM defencerun ORDER BY points DESC LIMIT 10";
        using (connection = new MySqlConnection(connectionString))
        {
            connection.Open();
            MySqlCommand command = connection.CreateCommand();
            command.CommandText = runQuery;
            MySqlDataReader reader = command.ExecuteReader();
            
            int ranking = 1;
            if (reader.HasRows)
            {

                while (reader.Read())
                {
                    int waves = reader.GetInt32("survivedRounds");
                    float accuracy = reader.GetFloat("gunaccuracy");
                    int points = reader.GetInt32("points");
                    string playerName = reader.GetString("player");
                    rankingText += ranking.ToString() + " - " + playerName + " | " + waves.ToString() + " | " + points.ToString() + " | " + accuracy.ToString() + "%\n";
                    ranking++;
                }
            }
        }
        return rankingText;
    }

    public string GetUserPersonalBestRun(string username)
    {   
        bool foundPlayerBest = false;
        string bestRun = "";
        int playerBestRanking = 99999;
        string allRunsQuery = "SELECT * FROM defencerun ORDER BY points DESC";
        using (connection = new MySqlConnection(connectionString))
        {
            connection.Open();
            MySqlCommand command = connection.CreateCommand();
            command.CommandText = allRunsQuery;
            MySqlDataReader reader = command.ExecuteReader();
            
            int runsTotal = 0;
            
            
            if (reader.HasRows)
            {
                while (reader.Read())
                {
                    runsTotal += 1;
                    if (reader.GetString("player") != username)
                    {
                        continue;
                    }
                    else
                    {
                        foundPlayerBest = true;
                        int waves = reader.GetInt32("survivedRounds");
                        float accuracy = reader.GetFloat("gunaccuracy");
                        int points = reader.GetInt32("points");
                        bestRun = waves.ToString() + " | " + points.ToString() + " |" + accuracy.ToString() + "%";
                        playerBestRanking = runsTotal;
                        break;
                    }
                }
            }
            reader.Close();
        }
        if (foundPlayerBest)
        {
            return playerBestRanking.ToString() + ". - " + bestRun;
        }
        else return "N/A";
        
    }

    public int GetRobotsDestroyedByPlayer(string username)
    {   
        int destroyedRobotsAmount = 0;
        string robotQuery = $"SELECT destroyedRobots FROM player WHERE username = '{username}'";
        using (connection = new MySqlConnection(connectionString))
        {
            connection.Open();
            MySqlCommand command = connection.CreateCommand();
            command.CommandText = robotQuery;
            MySqlDataReader reader = command.ExecuteReader();
            
            if (reader.HasRows)
            {
                while (reader.Read())
                {
                    destroyedRobotsAmount = reader.GetInt32("destroyedRobots");
                }
            }

        }
        return destroyedRobotsAmount;
    }

    public void UpdatePlayerRobotsDestroyedAmount(string username, int robotsDestroyed)
    {
        int recordedKills = GetRobotsDestroyedByPlayer(username);
        int updatedAmount = robotsDestroyed + recordedKills;
        string updateQuery = $"UPDATE player SET destroyedRobots = {updatedAmount} WHERE username = '{username}'";
        using (connection = new MySqlConnection(connectionString))
        {
            connection.Open();
            MySqlCommand command = connection.CreateCommand();
            command.CommandText = updateQuery;
            command.ExecuteNonQuery();
        }
    }
}
