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

	// Called when the node enters the scene tree for the first time.
	public override void _Ready()
	{
        connection = new MySqlConnection(connectionString);
    }

	public bool UsernameExists(string userName)
	{
		string query = $"SELECT * FROM player WHERE username = '{userName}'";
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

    public void RegisterUser(string userName)
    {
        connection = new MySqlConnection(connectionString);
        connection.Open();
        string query = $"INSERT INTO player (username, credits, accuracy, destroyedRobots) VALUES ('{userName}', 100, 100, 0)";
        MySqlCommand command = connection.CreateCommand();
        command.CommandText = query;
        command.ExecuteNonQuery();
        connection.Close();
    }

    //Check if the specified user own the specififed gun: pistol, smg or shotgun.
    //returns true, if there is an instance id with teh user's username and weapontype specified.
    public bool isOwned(string owner, string gunType)
    {
        string weaponInstanceID = owner + gunType;
        string query = $"SELECT * FROM weaponInstance WHERE instanceID = '{weaponInstanceID}'";
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
        reader.Close();
        connection.Close();
        return false;
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
        connection = new MySqlConnection(connectionString);
        connection.Open();
        MySqlCommand command = connection.CreateCommand();
        command.CommandText = query;
        command.ExecuteNonQuery();
        connection.Close();
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

        connection = new MySqlConnection(connectionString);
        connection.Open();
        MySqlCommand command = connection.CreateCommand();
        command.CommandText = upgradeLvlQuery;
        MySqlDataReader reader = command.ExecuteReader();
        if (reader.HasRows)
        {
            while (reader.Read())
            {
                return reader.GetInt32("upgradeLevel");
            }
        }
        return 1;
    }
    public int getUserCredits(string userName)
    {
        int creditsAmount = 0;
        string query = $"SELECT credits FROM player WHERE username = '{userName}'";
        connection = new MySqlConnection(connectionString);
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
            reader.Close();
        }
        else
        {
            reader.Close();
        }
        connection.Close();
        return creditsAmount;
    }

    public int GetWeaponPrice(string weaponType)
    {
        string query = $"SELECT purchaseprice from weapon where weapontype = '{weaponType}'";
        connection = new MySqlConnection(connectionString);
        connection.Open();
        MySqlCommand command = connection.CreateCommand();
        command.CommandText = query;
        MySqlDataReader reader = command.ExecuteReader();
        int price = 0;
        if (reader.HasRows)
        {
            while (reader.Read())
            {
                price = reader.GetInt32("purchaseprice");
            }
            reader.Close();
            connection.Close();
            return price;
        }
        price = 9999;
        return price;
    }

    public void updateUserCredits(string username, int credits)
    {
        string awardQuery = $"UPDATE player SET credits = {credits} WHERE username = '{username}'";
        connection = new MySqlConnection(connectionString);
        connection.Open();
        MySqlCommand command = connection.CreateCommand();
        command.CommandText = awardQuery;
        command.ExecuteNonQuery();
        connection.Close();
    }

    public string GetPlayerAverageAccuracy(string username)
    {
        //If the player doesn't have any run entries, there will be no data, so default is 100%
        string accuracyQuery = $"SELECT IFNULL(AVG(gunAccuracy),100) FROM defencerun WHERE player = '{username}'";


        connection = new MySqlConnection(connectionString);
        connection.Open();
        MySqlCommand command = connection.CreateCommand();
        command.CommandText = accuracyQuery;
        //string result = command.ExecuteScalar().ToString();
        //string formattedResult = result.ToString("0.00");
        double result = Convert.ToDouble(command.ExecuteScalar());

        connection.Close();
        
        return result.ToString("0.00");
    }

    public void UpdatePlayerAccuracy(string username)
    {
        float averageAccuracy = GetPlayerAverageAccuracy(username).ToFloat();
        string formattedAvgAccuracy = averageAccuracy.ToString(CultureInfo.InvariantCulture); //Gotta format it to not have comma as decimal point
        string updateAccuracyQuery = $"UPDATE player SET accuracy = {formattedAvgAccuracy} WHERE username = '{username}'";
        connection = new MySqlConnection(connectionString);
        connection.Open();
        MySqlCommand command = connection.CreateCommand();
        command.CommandText = updateAccuracyQuery;
        command.ExecuteNonQuery();
        connection.Close();
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
        connection = new MySqlConnection(connectionString);
        connection.Open();
        MySqlCommand command = connection.CreateCommand();

        command.CommandText = weaponInstanceQuery;
        command.ExecuteNonQuery();

        command.CommandText = playerQuery;
        command.ExecuteNonQuery();
        connection.Close();

        //After creating gun ownership, gotta add lvl 1 upgrades
        AddBaseUpgrades(username, gunType);
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
        connection = new MySqlConnection(connectionString);
        connection.Open();
        MySqlCommand command = connection.CreateCommand();
        command.CommandText = purchaseQuery;
        command.ExecuteNonQuery();
        string removeCreditsQuery = $"UPDATE player SET credits = {credits - upgradePrice} WHERE username = '{username}'";
        command.CommandText = removeCreditsQuery;
        command.ExecuteNonQuery();
        connection.Close();
    }
    public int GetUpgradePrice(string upgradeID)
    {
        string query = $"SELECT upgradePrice from weaponupgrade where upgradeId = '{upgradeID}'";
        connection = new MySqlConnection(connectionString);
        connection.Open();
        MySqlCommand command = connection.CreateCommand();
        command.CommandText = query;
        MySqlDataReader reader = command.ExecuteReader();
        int price = 0;
        if (reader.HasRows)
        {
            while (reader.Read())
            {
                price = reader.GetInt32("upgradePrice");
            }
            reader.Close();
            connection.Close();
            return price;
        }
        reader.Close();
        connection.Close();
        price = 9999;
        return price;
    }

    public int getOwnedEquipmentAmount(string username, string equipmentType)
    {
        string equipmentQuery = $"SELECT equipmentamount FROM equipmentinstance WHERE equipmentOwner = '{username}' AND equipmentType = '{equipmentType}'";
        connection = new MySqlConnection(connectionString);
        connection.Open();
        MySqlCommand command = connection.CreateCommand();
        command.CommandText = equipmentQuery;
        MySqlDataReader reader = command.ExecuteReader();
        int ownedAmount = 0;
        if(reader.HasRows)
        {
            while (reader.Read())
            {
                ownedAmount = reader.GetInt32("equipmentAmount");
            }
        }
        reader.Close();
        connection.Close();
        return ownedAmount;
    }

    public void updateOwnedEquipmentAmount(string username, string equipmentType, int ownedAmount)
    {
        string instanceID = username + equipmentType;
        string updateEquipmentQuery = $"UPDATE equipmentinstance SET equipmentAmount = {ownedAmount} WHERE instanceID = '{instanceID}'";
        connection = new MySqlConnection(connectionString);
        connection.Open();
        MySqlCommand command = connection.CreateCommand();
        command.CommandText = updateEquipmentQuery;
        command.ExecuteNonQuery();
        connection.Close();
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
        connection = new MySqlConnection(connectionString);
        connection.Open();
        MySqlCommand command = connection.CreateCommand();
        command.CommandText = updateCreditsQuery;
        command.ExecuteNonQuery();
        connection.Close();
    }

    public bool EquipmentRegisteredToUser(string username, string equipmentType)
    {
        string equipmentInstanceID = username + equipmentType;
        string equipmentQuery = $"SELECT * FROM equipmentInstance WHERE instanceid = '{equipmentInstanceID}'";
        connection = new MySqlConnection(connectionString);
        connection.Open();
        MySqlCommand command = connection.CreateCommand();
        command.CommandText = equipmentQuery;
        MySqlDataReader reader = command.ExecuteReader();
        if (reader.HasRows)
        {
            reader.Close();
            connection.Close();
            return true;
        }
        reader.Close();
        connection.Close();
        return false;
    }

    public void CreateNewEquipmentInstance(string username, string equipmentType, int equipmentAmount)
    {
        string equipmentInstanceID = username + equipmentType;
        GD.Print("C# CreateNewEquipmentInstance() - creating new equipment instance for " + username + " with id " + equipmentInstanceID);
        string createEquipmentQuery = $"INSERT INTO equipmentInstance (equipmentOwner, equipmentType, equipmentAmount, instanceID) VALUES ('{username}', '{equipmentType}', {equipmentAmount}, '{equipmentInstanceID}')";
        connection = new MySqlConnection(connectionString);
        connection.Open();
        MySqlCommand command = connection.CreateCommand();
        command.CommandText = createEquipmentQuery;
        command.ExecuteNonQuery();
        connection.Close();
    }
    public int getEquipmentPrice(string equipmentType)
    {
        string priceQuery = $"SELECT equipmentPrice FROM equipment WHERE equipmentType = '{equipmentType}'";
        connection = new MySqlConnection(connectionString);
        connection.Open();
        MySqlCommand command = connection.CreateCommand();
        command.CommandText = priceQuery;
        MySqlDataReader reader = command.ExecuteReader();
        int price = 0;
        if (reader.HasRows)
        {
            while (reader.Read())
            {
                price = reader.GetInt32("equipmentPrice");
            }

        }
        reader.Close();
        connection.Close();
        return price;
    }

    public int GetRobotsDestroyedByWeapon(string weaponID)
    {

        string robotsDestroyedQuery = $"SELECT destroyedRobots FROM weaponinstance WHERE instanceID = '{weaponID}'";
        connection = new MySqlConnection(connectionString);
        connection.Open();
        MySqlCommand command = connection.CreateCommand();
        command.CommandText = robotsDestroyedQuery;
        MySqlDataReader reader = command.ExecuteReader();
        int robotsDestroyed = 0;
        if (reader.HasRows)
        {
            while (reader.Read())
            {
                robotsDestroyed = reader.GetInt32("destroyedRobots");
            }    
        }
        reader.Close();
        connection.Close ();
        return robotsDestroyed;
    }

    public void UpdateWeaponDestroyedRobotsAmount(string username, string weaponType, int amount)
    {
        string weaponID = username + weaponType;
        int recordedDestructionAmount = GetRobotsDestroyedByWeapon(weaponID);
        int updatedAmount = amount + recordedDestructionAmount;
        string updateDestructionAmountQuery = $"UPDATE weaponinstance SET destroyedRobots = {updatedAmount} WHERE instanceID = '{weaponID}'";
        connection = new MySqlConnection(connectionString);
        connection.Open();
        MySqlCommand command = connection.CreateCommand();
        command.CommandText = updateDestructionAmountQuery;
        command.ExecuteNonQuery();
        connection.Close();
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
        connection = new MySqlConnection(connectionString) ;
        connection.Open();
        MySqlCommand command = connection.CreateCommand();
        command.CommandText = runQuery;
        command.ExecuteNonQuery();
    }

    public string GetTop10Runs()
    {
        string runQuery = "SELECT survivedrounds, gunaccuracy, points, player FROM defencerun ORDER BY points DESC LIMIT 10";
        connection = new MySqlConnection(connectionString);
        connection.Open();
        MySqlCommand command = connection.CreateCommand();
        command.CommandText = runQuery;
        MySqlDataReader reader = command.ExecuteReader();
        string rankingText = "";
        int ranking = 1;
        if (reader.HasRows)
        {

            while (reader.Read())
            {
                int waves = reader.GetInt32("survivedRounds");
                float accuracy = reader.GetFloat("gunaccuracy");
                int points = reader.GetInt32("points");
                string playerName = reader.GetString("player");
                rankingText += ranking.ToString()+ " - " + playerName + " | " + waves.ToString() + " | " + points.ToString() + " | " + accuracy.ToString() + "%\n";
                ranking++;
            }
        }
        reader.Close();
        connection.Close();
        return rankingText;
    }

    public string GetUserPersonalBestRun(string username)
    {
        string allRunsQuery = "SELECT * FROM defencerun ORDER BY points DESC";
        connection = new MySqlConnection(connectionString);
        connection.Open();
        MySqlCommand command = connection.CreateCommand();
        command.CommandText = allRunsQuery;
        MySqlDataReader reader = command.ExecuteReader();
        string bestRun = "";
        int runsTotal = 0;
        int playerBestRanking = 99999;
        bool foundPlayerBest = false;
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
        connection.Close ();
        if (foundPlayerBest)
        {
            return playerBestRanking.ToString() + ". - " + bestRun;
        }
        else return "N/A";
        
    }

    public int GetRobotsDestroyedByPlayer(string username)
    {
        string robotQuery = $"SELECT destroyedRobots FROM player WHERE username = '{username}'";
        connection = new MySqlConnection(connectionString);
        connection.Open();
        MySqlCommand command = connection.CreateCommand();
        command.CommandText = robotQuery;
        MySqlDataReader reader = command.ExecuteReader();
        int destroyedRobotsAmount = 0;
        if (reader.HasRows)
        {
            while (reader.Read())
            {
                destroyedRobotsAmount = reader.GetInt32("destroyedRobots");
            }
        }
        reader.Close();
        connection.Close();
        return destroyedRobotsAmount;
    }

    public void UpdatePlayerRobotsDestroyedAmount(string username, int robotsDestroyed)
    {
        int recordedKills = GetRobotsDestroyedByPlayer(username);
        int updatedAmount = robotsDestroyed + recordedKills;
        string updateQuery = $"UPDATE player SET destroyedRobots = {updatedAmount} WHERE username = '{username}'";
        connection = new MySqlConnection(connectionString);
        connection.Open();
        MySqlCommand command = connection.CreateCommand();
        command.CommandText = updateQuery;
        command.ExecuteNonQuery();
    }
}
