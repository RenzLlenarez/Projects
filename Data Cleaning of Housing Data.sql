
/*
Hello, my name is Renz Llenarez, a Data analyst. Thank you for checking out this code. I use a lot of comments for proper documentation.
Sometimes, next to a line of code, for me to remember what it actually does.
The Project Title is 'Data Cleaning in SQL with Housing Data'
For this project, I imported one excel file and named the table dbo.Housing
*/

----------------------------------------------------------------------------------------------------------------------------------------

Select *
From Project.dbo.Housing

----------------------------------------------------------------------------------------------------------------------------------------

-- How to Change the Date Format
-- make the date easier to read by standardizing the format

ALTER TABLE Housing -- add new column named SaleDate2 then declare data type
Add SaleDate2 Date;

Update Housing -- Update table, set the new column with converted 'saledate' existing dates
SET SaleDate2 = CONVERT(Date,SaleDate)

Select SaleDate, SaleDate2 -- display old and new date column
From Project.dbo.Housing

----------------------------------------------------------------------------------------------------------------------------------------

-- How to populate property address data
-- There are some null values on the property address and duplicate values on the parcelID
-- I needed to replace the null values on the property address with the correct value on the duplicated parcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress) -- Joining table by itself, 'ISNULL' if the value is null, populate with 2nd value
From Project.dbo.Housing a
JOIN Project.dbo.Housing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

Update a -- update to populate the null values, run the above code again to see results, zero table will display because there is no NULL values anymore
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From Project.dbo.Housing a
JOIN Project.dbo.Housing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

----------------------------------------------------------------------------------------------------------------------------------------

-- Updating the address, separating address and city, making new columns for address and city
-- using substring

Select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address --substring(column_name, position, actual_string) charindex is looking for specific value. -1 is to remove the comma
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as City --same concept as above, the start position is the comma then 'LEN(propertyaddress)' is the remaining string, +1 is to remove the comma
From Project.dbo.Housing

ALTER TABLE Housing -- add new column named Address
Add Property_Address NVARCHAR(255);

Update Housing -- Update table, set the new column with substring as address
SET Property_Address = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE Housing -- add new column named City
Add Property_City NVARCHAR(255);

Update Housing -- Update table, set the new column with substring as city
SET Property_City = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

Select PropertyAddress, Property_Address, Property_City -- display old and new columns
From Project.dbo.Housing

-- Updating the 'OwnerAddress' Separating Address, City, and State
-- using parsename

Select -- The OwnerAddress are separated by commas, parsename looks for period. that's why we have to replace the ',' to '.' then the position is backwards, that's why it is 3,2,1
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) as Address
,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) as City
,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) as State
From Project..Housing

ALTER TABLE Housing -- add new column named Owner_Address
Add Owner_Address NVARCHAR(255);

Update Housing -- Update table, set the new column with parsename as address
SET Owner_Address = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE Housing -- add new column named Owner_City
Add Owner_City NVARCHAR(255);

Update Housing -- Update table, set the new column with parsename as city
SET Owner_City = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE Housing -- add new column named Owner_State
Add Owner_State NVARCHAR(255);

Update Housing -- Update table, set the new column with parsename as state
SET Owner_State = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

Select OwnerAddress, Owner_Address, Owner_City, Owner_State --display old and new columns
From Project..Housing

----------------------------------------------------------------------------------------------------------------------------------------

-- How to change Y and N to yes and No to 'Sold as Vacant' Column

Select Distinct(SoldAsVacant), Count(SoldasVacant) --distinct filters out the different values, count displays the total count of each value
From Project..Housing
Group by SoldAsVacant
Order by Count(SoldasVacant) -- or 2

Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant -- else soldasvacant stays the same
	   END
From Project..Housing

Update Housing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant -- else soldasvacant stays the same
	   END -- run the first code to check

----------------------------------------------------------------------------------------------------------------------------------------

-- How to remove duplicates

WITH row_num_cte as(
Select *
		,ROW_NUMBER() OVER (			-- assuming if all these columns have the same value, then all remaining columns are also the same
		PARTITION BY ParcelID,			-- use of partition by is not necessary if there is no uniqueID
					 PropertyAddress,
					 SalePrice,
					 SaleDate,
					 LegalReference
					 ORDER BY UniqueID
					 ) as row_num		-- row_num returns the incremental value if it has one or more duplicates
From Project..Housing
)
DELETE -- Select * to check
From row_num_cte
Where row_num > 1 -- had to use CTE to work, if number returns more than 1, then the row is a duplicate

----------------------------------------------------------------------------------------------------------------------------------------

-- How to delete columns

Select *
From Project.dbo.Housing

ALTER TABLE Project.dbo.housing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress
