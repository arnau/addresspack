/* © Ordnance Survey Limited 2015. All rights reserved. */

CREATE TABLE IF NOT EXISTS table_info (
  id          integer PRIMARY KEY NOT NULL,
  name        text    NOT NULL,
  definition  text    NOT NULL,
  description text
);

CREATE TABLE IF NOT EXISTS column_info (
  id         text          NOT NULL,
  table_id   integer       NOT NULL,
  ordinal_position integer NOT NULL,
  definition text          NOT NULL,
  data_type text           NOT NULL,
  is_nullable bool         DEFAULT false,
  CONSTRAINT column_pk     PRIMARY KEY (id, table_id)
);

INSERT OR REPLACE INTO table_info (id, name, definition, description) VALUES
(10, 'header',
  'A structured entry that provides key information about the source, time and supply mechanism of the AddressBase Premium file.',
  NULL),
(11, 'street',
  'A way or thoroughfare providing a right of way on foot, by cycle or by motor vehicle, or access to more than one property.',
  'This record assigns a Unique Street Reference Number (USRN) to each street and holds the start and end coordinates of the street feature with information about surface type and classification.'),
(15, 'street_descriptor',
  'A descriptive identifier providing additional information about the street feature.',
  'This record holds information about locality, town name and street name.'),
(21, 'basic_land_property_unit',
  'A BLPU is defined as a real-world object that is an ‘area of land, property or structure of fixed location having uniform occupation, ownership or function’.',
  'A real-world object that is of interest and within scope of the CLASS_SCHEME.'),
(23, 'application_cross_reference',
  'Application cross reference links to third party identifiers.',
  'AddressBase Premium application cross references contain a lookup between the AddressBase Premium UPRN and the unique identifiers of other relevant datasets.'),
(24, 'local_property_identifier',
  'An LPI is a structured entry that identifies a BLPU.',
  'A simple identifier or description for the object. The richness of the data structurewithin AddressBase Premium provides the facility to describe a BLPU by more than one LPI.'),
(28, 'delivery_point_address',
  'A Delivery Point Address is defined as a property that receives deliveries from Royal Mail®.',
  'The structure of this address is taken from Royal Mail Postcode Address File (PAF®) and other supplementary data files.'),
(29, 'metadata',
  'A structured entry providing metadata information such as the gazetteer owner, scope and character sets.',
  NULL),
(30, 'successor',
  'This record holds references to a UPRN and to any replacement UPRN, for example, if a building is split into two sub-buildings; the sub-building UPRNs will be referenced in the successor record.',
  'This record holds information about a UPRN and the UPRNs of the records that succeed that record.'),
(31, 'organisation',
  'A structured entry identifying the name of the current non-domestic occupier of the BLPU.',
  'This record holds information about the organisation of the record.'),
(32, 'classification',
  'A structured entry that provides the code for the type of BLPU and the classification scheme from which the code is taken.',
  'This record holds the classification of a property and allows one to search upon the use of a feature.'),
(99, 'trailer',
  'A structured entry which terminates the file. This includes information on the record counts, and next volume number.',
  NULL);

INSERT OR REPLACE INTO column_info (id, table_id, ordinal_position, definition, data_type, is_nullable) VALUES
('record_id', 10, 1, 'Identifies the record as a Header Record (type 10).', 'integer(2)', false),
('custodian_name', 10, 2, 'Name of the data provider organisation.', 'text', false),
('local_custodian_code', 10, 3, 'Unique identifier for the data provider code.', 'integer(4)', false),
('process_date', 10, 4, 'The date on which the data supply was generated.', 'date', false),
('volume_number', 10, 5, 'The sequential number of the volume in the transfer set. Please note for Geographic supplies this number will always be zero ‘0’.', 'integer(3)', false),
('entry_date', 10, 6, 'Date of data entry for this volume.', 'date', false),
('time_stamp', 10, 7, 'Time of file creation in HH:MM:SS format in a 24 hour clock.', 'time', false),
('version', 10, 8, 'Version number of the product schema e.g 1.0, 2.0', 'char(7)', false),
('file_type', 10, 9, 'States whether the data supply is a Full Supply, or Change Only Supply.', 'char(1)', false),

('record_id', 11, 1, 'Identifies this record as a Street Record (type 11).', 'integer(2)', false),
('change_type', 11, 2, 'Type of record change.', 'char(1)', false), -- ChangeTypeCode
('pro_order', 11, 3, 'The order in which the records were processed in to create the data supply.', 'integer(16)', false),
('usrn', 11, 4, 'Unique Street Reference Number (USRN) - the unique key for the record and primary key for the Street table.', 'integer(8)', false),
('record_type', 11, 5, 'Description of the street record type, for example whether it is a named or numbered street.', 'char(1)', false),
('swa_org_ref_naming', 11, 6, 'The code which identifies the Street Naming and Numbering Authority or the Local Highway Authority.', 'integer(4)', false),
('state', 11, 7, 'A code identifying the current state of the Street, ‘Open’ for example.', 'char(1)', true), -- StreetStateCode
('state_date', 11, 8, 'Date at which the street achieved its current state as referenced in the ‘State’ column.', 'date', true),
('street_surface', 11, 9, 'A code to indicate the surface finish of the street.', 'char(1)', true), -- StreetSurfaceCode
('street_classification', 11, 10, 'A code for the primary street classification, for example denoting it to be ‘open to all vehicles’.', 'char(1)', true), -- StreetClassificationCode
('version', 11, 11, 'Version number of the street record.', 'integer(3)', false),
('street_start_date', 11, 12, 'Date this record or version was inserted into the database.', 'date', false),
('street_end_date', 11, 13, 'Date on which the street was closed in the product database. This can occur due to the street being permanently closed in the real world.', 'date', true),
('last_update_date', 11, 14, 'The date on which any attribute of the Record was last changed.', 'date', false),
('record_entry_date', 11, 15, 'The date that the record was entered into the Local Authority database.', 'date', false),
('street_start_x', 11, 16, 'A value in metres defining the x and y location in accordance to the British National Grid for the start point of the street.', 'numeric(8, 2)', false),
('street_start_y', 11, 17, 'A value in metres defining the x and y location in accordance to the British National Grid for the start point of the street.', 'numeric(9, 2)', false),
('street_start_lat', 11, 18, 'A value defining the Latitude and Longitude start point of the street in accordance with the ETRS89 coordinate reference system.', 'numeric(9, 7)', false),
('street_start_long', 11, 19, 'A value defining the Latitude and Longitude start point of the street in accordance with the ETRS89 coordinate reference system.', 'numeric(8, 7)', false),
('street_end_x', 11, 20, 'A value in metres defining the x and y location in accordance to the British National Grid for the start point of the street.', 'numeric(8, 2)', false),
('street_end_y', 11, 21, 'A value in metres defining the x and y location in accordance to the British National Grid for the start point of the street.', 'numeric(9, 2)', false),
('street_end_lat', 11, 22, 'A value defining the Latitude and Longitude start point of the street in accordance with the ETRS89 coordinate reference system.', 'numeric(9, 7)', false),
('street_end_long', 11, 23, 'A value defining the Latitude and Longitude start point of the street in accordance with the ETRS89 coordinate reference system.', 'numeric(8, 7)', false),
('street_tolerance', 11, 24, 'The accuracy of data capture (in metres) to which the Street Start and End coordinates have been captured.', 'integer(3)', false),

('record_identifier', 15, 1, 'Identifies this record as a Street Descriptor record (type 15).', 'integer(2)', false),
('change_type', 15, 2, 'Type of record change.', 'char(1)', false), -- ChangeTypeCode
('pro_order', 15, 3, 'The order in which the records were processed in to create the data supply.', 'integer(16)', false),
('usrn', 15, 4, 'Unique Street Reference Number (USRN) - used as foreign key to reference the corresponding street record.', 'integer(8)', false),
('street_description', 15, 5, 'Name, description or Street number for this record.', 'text', false),
('locality', 15, 6, 'A locality defines an area or geographical identifier within a town, village or hamlet. Locality represents the lower level geographical area. The locality field should be used in conjunction with the town name and street description fields to uniquely identify geographic area where there may be more than one within an administrative area.', 'text', true),
('town_name', 15, 7, 'Town Name.', 'text', true),
('administrative_area', 15, 8, 'Local Highway Authority name for the area this record exists within.', 'text', false),
('language', 15, 9, 'A code identifying the language in use for the record.', 'char(3)', false), -- LanguageCode
('start_date', 15, 10, 'Date this record was first created in the database.', 'date', false),
('end_date', 15, 11, 'The date on which this record ceased to exist.', 'date', true),
('last_update_date', 15, 12, 'The date on which an attribute on this record was last changed.', 'date', false),
('entry_date', 15, 13, 'The date on which the record was entered into the Local Authority database.', 'date', false),

('record_identifier', 21, 1, 'Identifies this record as a BLPU Record (type 21).', 'integer(2)', false),
('change_type', 21, 2, 'Type of record change.', 'char(1)', false), -- ChangeTypeCode
('pro_order', 21, 3, 'The order in which the records were processed in to create the data supply.', 'integer(16)', false),
('uprn', 21, 4, 'Unique Property Reference Number (UPRN) assigned by the LLPG Custodian or Ordnance Survey.', 'integer(12)', false),
('logical_status', 21, 5, 'Logical status of this address record as given by the local custodian. This attribute shows whether the address is currently live, provisional or historic.', 'char(1)', false), -- LogicalStatusCode
('blpu_state', 21, 6, 'A code identifying the current state of the BLPU.', 'char(1)', true), -- BlpuStateCode
('blpu_state_date', 21, 7, 'Date at which the BLPU achieved its current state as defined in the BLPU State field.', 'date', true),
('parent_uprn', 21, 8, 'UPRN of the parent Record if a parent child relationship exists.', 'integer(12)', true),
('x_coordinate', 21, 9, 'A value in metres defining the x and y location in accordance to the British National Grid.', 'numeric(8, 2)', false),
('y_coordinate', 21, 10, 'A value in metres defining the x and y location in accordance to the British National Grid.', 'numeric(9, 2)', false),
('latitude', 21, 11, 'A value defining the Latitude and Longitude location in accordance with the ETRS89 coordinate reference system.', 'numeric(9, 7)', false),
('longitude', 21, 12, 'A value defining the Latitude and Longitude location in accordance with the ETRS89 coordinate reference system.', 'numeric(8, 7)', false),
('rpc', 21, 13, 'Representative Point Code: this describes the accuracy of the coordinate that has been allocated to the BLPU as indicated by the local authority custodian.', 'char(1)', false), -- RpcCode
('local_custodian_code', 21, 14, 'Unique identifier of the Local Authority Custodian responsible for the maintenance of this record.', 'integer(4)', false),
('country', 21, 15, 'The country in which a record can be found. This is calculated by performing an intersection with OS Boundary Line. This means records such as wind and fish farms will be assigned a value of ‘J’. Please see CountryCode for more information.', 'char(1)', false), -- CountryCode
('start_date', 21, 16, 'The date on which the address record was inserted into the database.', 'date', false),
('end_date', 21, 17, 'The date on which the address record was closed in the database.', 'date', true),
('last_update_date', 21, 18, 'The date on which any of the attributes on this record were last changed.', 'date', false),
('entry_date', 21, 19, 'The date on which this record was inserted into the Local Authority database.', 'date', false),
('addressbase_postal', 21, 20, 'Identifies addresses which are believed to be capable of receiving mail as defined specifically for the AddressBase products, and details their relationship with other AddressBase Postal records. N.B. this field identifies some addresses which the AddressBase product believes to be capable of receiving mail which are not contained within the Royal Mail PAF database, such as flats behind a front door with single letter box.', 'char(1)', false), -- AddressbasePostalCode
('postal_code_locator', 21, 21, 'This field contains the Royal Mail Postcode Address File (PAF) postcode where the local authority address has been matched to PAF, i.e. the POSTCODE field found within the Delivery Point Address table. Where a match has not been made, the postcode information is sourced from the local authority in collaboration with Royal Mail. Where the local authority do not hold a current valid postcode Code-Point with Polygons® is used to spatially derive the postcode based on the position of the coordinates. This filed is always assigned the Code-Point with Polygons® Postcode for Street Records (Classification “PS”). This field must be used in conjunction with the RPC field to determine the accuracy of its position.', 'char(8)', false),
('multi_occ_count', 21, 22, 'This is a count of all of the child UPRNs for this record where a parent-child relationship exists.', 'integer(4)', false),

('record_identifier', 23, 1, 'Identifies this record as an Application Cross Reference Record (type 23).', 'integer(2)', false),
('change_type', 23, 2, 'Type of record change.', 'char(1)', false), -- ChangeTypeCode
('pro_order', 23, 3, 'The order in which the records were processed in to create the data supply.', 'integer(16)', false),
('uprn', 23, 4, 'Unique Property Reference Number (UPRN) - foreign key used to reference the application cross reference record to the corresponding BLPU.', 'integer(12)', false),
('xref_key', 23, 5, 'Unique key for the application cross reference record and primary key for this table.', 'char(14)', false),
('cross_reference', 23, 6, 'Primary key of corresponding record in an external dataset.', 'text', false),
('version', 23, 7, 'Certain data sources may reference objects with lifecycles. This field enables users to reference specific versions of an object e.g. OS MasterMap Topographic Layer TOID and Version.', 'integer(3)', true),
('source', 23, 8, 'External dataset identity.', 'char(6)', false),
('start_date', 23, 9, 'Date the feature was matched to the cross reference dataset for the first time.', 'date', false),
('end_date', 23, 10, 'The date on which the external cross reference was no longer valid.', 'date', true),
('last_update_date', 23, 11, 'The date on which any attribute on this record was last changed.', 'date', false),
('entry_date', 23, 12, 'The date on which the Local Authority record matched to the cross reference was inserted into the Local Authority database.', 'date', false),

('record_identifier', 24, 1, 'Identifies this record as an Application Cross Reference Record (type 24).', 'integer(2)', false),
('change_type', 24, 2, 'Type of record change.', 'char(1)', false), -- ChangeTypeCode
('pro_order', 24, 3, 'The order in which the records were processed in to create the data supply.', 'integer(16)', false),
('uprn', 24, 4, 'Unique Property Reference Number (UPRN) - foreign key used to reference the LPI to the corresponding BLPU.', 'integer(12)', false),
('lpi_key', 24, 5, 'Unique key for the LPI and primary key for this table.', 'char(14)', false),
('language', 24, 6, 'A code that identifies the language used for the LPI record.', 'char(3)', false), -- LanguageCode
('logical_status', 24, 7, 'Logical status of this record.', 'char(1)', false), -- LogicalStatusCode
('start_date', 24, 8, 'Date that this LPI record was first loaded into the database.', 'date', false),
('end_date', 24, 9, 'The date this record ceased to exist in the database.', 'date', true),
('last_update_date', 24, 10, 'The last date an attribute on this record was last changed.', 'date', false),
('entry_date', 24, 11, 'The date on which the record was inserted into the Local Authority database.', 'date', false),
('sao_start_number', 24, 12, 'The number of the secondary addressable object (SAO) or the start of the number range.', 'integer(4)', true),
('sao_start_suffix', 24, 13, 'The suffix to the SAO_START_NUMBER.', 'char(2)', true),
('sao_end_number', 24, 14, 'The end of the number range for the SAO, where the SAO_START_NUMBER contains the first number in the range.', 'integer(4)', true),
('sao_end_suffix', 24, 15, 'The suffix to the SAO_END_NUMBER.', 'char(2)', true),
('sao_text', 24, 16, 'Contains the building name or description for the SAO.', 'text', true),
('pao_start_number', 24, 17, 'The number of the primary addressable object (PAO) or the start of the number range.', 'integer(4)', true),
('pao_start_suffix', 24, 18, 'The suffix to the PAO_START_NUMBER.', 'char(2)', true),
('pao_end_number', 24, 19, 'The end of the number range for the PAO where the PAO_START_NUMBER contains the first number in the range.', 'integer(4)', true),
('pao_end_suffix', 24, 20, 'The suffix to the PAO_END_NUMBER.', 'char(2)', true),
('pao_text', 24, 21, 'Contains the building name or description for the PAO.', 'text', true),
('usrn', 24, 22, 'Unique Street Reference Number (USRN) - foreign key linking the Street record to the LPI record.', 'integer(8)', false),
('usrn_match_indicator', 24, 23, 'This field indicates how the item was matched to a Street. 1 is matched manually to the most accessible USRN and 2 is matched spatially to the nearest USRN, which may not be the nearest accessible street.', 'char(1)', false), -- USRNMatchIndicatorCode
('area_name', 24, 24, 'Third level of geographic area name, for example, to record island names or property groups such as crofts.', 'text', true),
('level', 24, 25, 'Detail on the vertical position of the property if known and provided by the Local Authority Custodian.', 'text', true),
('official_flag', 24, 26, 'Status of the Address.', 'char(1)', true), -- OfficialFlagCode

('record_identifier', 28, 1, 'Identifies the record as a Royal Mail Delivery Point Address Record (type 28).', 'integer(2)', false),
('change_type', 28, 2, 'Type of record change.', 'char(1)', false), -- ChangeTypeCode
('pro_order', 28, 3, 'The order in which the records were processed in to create the data supply.', 'integer(16)', false),
('uprn', 28, 4, 'Unique Property Reference Number (UPRN) - foreign key used to reference the DPA record to the corresponding BLPU.', 'integer(12)', false),
('udprn', 28, 5, 'Royal Mail’s Unique Delivery Point Reference Number (UDPRN) and the Primary key for this table.', 'integer(8)', false),
('organisation_name', 28, 6, 'The organisation name is the business name given to a delivery point within a building or small group of buildings. For example: TOURIST INFORMATION CENTRE This field could also include entries for churches, public houses and libraries. Source: Royal Mail', 'text', true),
('department_name', 28, 7, 'For some organisations, department name is indicated because mail is received by subdivisions of the main organisation at distinct delivery points. For example: Organisation Name: ABC COMMUNICATIONS RM Department Name: MARKETING DEPARTMENT Source: Royal Mail', 'text', true),
('sub_building_name', 28, 8, 'The sub-building name and/or number are identifiers for subdivisions of properties. For example: Sub-building Name: FLAT 3 Building Name: POPLAR COURT Thoroughfare: LONDON ROAD NOTE: If the above address is styled 3 POPLAR COURT, all the text will be shown in the Building Name attribute and the Sub-building Name will be empty. The building number will be shown in this field when it contains a range, decimal or non-numeric character (see Building Number). Source: Royal Mail', 'text', true),
('building_name', 28, 9, 'The building name is a description applied to a single building or a small group of buildings, such as Highfield House. This also includes those building numbers that contain non-numeric characters, such as 44A. Some descriptive names, when included with the rest of the address, are sufficient to identify the property uniquely and unambiguously, for example, MAGISTRATES COURT. Sometimes the building name will be a blend of distinctive and descriptive naming, for example, RAILWAY TAVERN (PUBLIC HOUSE) or THE COURT ROYAL (HOTEL). Source: Royal Mail', 'text', true),
('building_number', 28, 10, 'The building number is a number given to a single building or a small group of buildings, thus identifying it from its neighbours, for example, 44. Building numbers that contain a range, decimals or non-numeric characters do not appear in this field but will be found in the buildingName or the sub-BuildingName fields. Source: Royal Mail', 'integer(4)', true),
('dependent_thoroughfare', 28, 11, 'In certain places, for example, town centres, there are named thoroughfares within other named thoroughfares, for example, parades of shops on a high street where different parades have their own identity. For example, KINGS PARADE, HIGH STREET and QUEENS PARADE, HIGH STREET. Source: Royal Mail', 'text', true),
('thoroughfare', 28, 12, 'A thoroughfare in AddressBase is fundamentally a road, track or named access route on which there are Royal Mail delivery points, for example, HIGH STREET. Source: Royal Mail', 'text', true),
('double_dependent_locality', 28, 13, 'This is used to distinguish between similar thoroughfares or the same thoroughfare within a dependent locality. For example, Millbrook Industrial Estate and Cranford Estate in this situation: BRUNEL WAY, MILLBROOK INDUSTRIAL ESTATE, MILLBROOK, SOUTHAMPTON and BRUNEL WAY, CRANFORD ESTATE, MILLBROOK, SOUTHAMPTON. Source: Royal Mail', 'text', true),
('dependent_locality', 28, 14, 'Dependent locality areas define an area within a post town. These are only necessary for postal purposes and are used to aid differentiation where there are thoroughfares of the same name in the same locality. For example, HIGH STREET in SHIRLEY and SWAYTHLING in this situation: HIGH STREET, SHIRLEY, SOUTHAMPTON and HIGH STREET, SWAYTHLING, SOUTHAMPTON. Source: Royal Mail', 'text', true),
('post_town', 28, 15, 'The town or city in which the Royal Mail sorting office is located which services this record. There may be more than one, possibly several, sorting offices in a town or city. Source: Royal Mail', 'text', false),
('postcode', 28, 16, 'A postcode is an abbreviated form of address made up of combinations of between five and seven alphanumeric characters. These are used by Royal Mail to help with the automated sorting of mail. A postcode may cover between 1 and 100 addresses. There are two main components of a postcode, for example, NW6 4DP: • The outward code (or ‘outcode’). The first two–four characters of the postcode constituting the postcode area and the postcode district, for example, NW6. It is the part of the postcode that enables mail to be sent from the accepting office to the correct area for delivery. • The inward code (or ‘incode’). The last three characters of the postcode constituting the postcode sector and the postcode unit, example, 4DP. It is used to sort mail at the local delivery office. Source: Royal Mail', 'text', false),
('postcode_type', 28, 17, 'Describes the address as a small or large user as defined by Royal Mail. Source: Royal Mail.', 'char(1)', false), -- PostcodeTypeCode
('delivery_point_suffix', 28, 18, 'A two character code uniquely identifying an individual delivery point within a postcode. Source: Royal Mail.', 'char(2)', false),
('welsh_dependent_thoroughfare', 28, 19, 'The Welsh translation of DEPENDENT_THOROUGHFARE Source: Royal Mail', 'text', true),
('welsh_thoroughfare', 28, 20, 'The Welsh translation of THOROUGHFARE. Source: Royal Mail', 'text', true),
('welsh_double_dependent_locality', 28, 21, 'The Welsh translation of Double Dependent Locality. Source: Royal Mail', 'text', true),
('welsh_dependent_locality', 28, 21, 'The Welsh translation of DEPENDENT_LOCALITY. Source: Royal Mail', 'text', true),
('welsh_post_town', 28, 22, 'The Welsh translation of post town value. Source: Royal Mail', 'text', true),
('po_box_number', 28, 23, 'Post Office Box (PO Box®) number. Source: Royal Mail', 'char(6)', true),
('process_date', 28, 24, 'The date on which the PAF record was processed into the database.', 'date', false),
('start_date', 28, 25, 'The date on which the address record was matched to the Delivery Point Address.', 'date', false),
('end_date', 28, 26, 'The date on which the PAF record no longer existed in the database.', 'date', true),
('last_update_date', 28, 27, 'The date on which any attribute on this record was last changed.', 'date', false),
('entry_date', 28, 28, 'The date on which the PAF record was first loaded by Geoplace.', 'date', false),

('record_identifier', 29, 1, 'Identifies the record as a Metadata Record (type 29).', 'integer(2)', false),
('gaz_name', 29, 2, 'Name of the Gazetteer, this will most likely reflect the product name e.g. AddressBase Premium.', 'text', false),
('gaz_scope', 29, 3, 'Description of the content of the gazetteer.', 'text', false),
('ter_of_use', 29, 4, 'Geographic domain of the gazetteer, for example, England, Wales and Scotland.', 'text', false),
('linked_data', 29, 5, 'List of other datasets used to contribute to the creation of the product.', 'text', false),
('gaz_owner', 29, 6, 'The organisation with overall responsibility for the gazetteer.', 'text', false),
('ngaz_freq', 29, 7, 'Frequency with which the data is maintained and sent to the customer.', 'char(1)', false),
('custodian_name', 29, 8, 'Organisation or department responsible for the compilation and maintenance of the data, for example Geoplace.', 'text', false),
('custodian_uprn', 29, 9, 'Unique Property Reference Number (UPRN) of the custodian location.', 'integer(12)', false),
('local_custodian_code', 29, 10, 'Four-digit code identifying the gazetteer custodian.', 'integer(4)', false),
('co_ord_system', 29, 11, 'Coordinate Reference System used in the gazetteer to describe the position, for example British National Grid.', 'text', false),
('co_ord_unit', 29, 12, 'Unit of measurement of coordinates.', 'text', false),
('meta_date', 29, 13, 'Date metadata was last updated.', 'date', false),
('class_scheme', 29, 14, 'Classification scheme (s) used in the Gazetteer.', 'text', false),
('gaz_date', 29, 15, 'Date at which the gazetteer can be considered to be current.', 'date', false),
('language', 29, 16, 'Language used for the descriptors within the gazetteer, for example ‘ENG’.', 'char(3)', false), -- LanguageCode
('character_set', 29, 17, 'The character set used in this gazetteer.', 'text', false),

('record_identifier', 30, 1, 'Identifies this record as a Successor Cross Reference (type 30).', 'integer(2)', false),
('change_type', 30, 2, 'Type of record change.', 'char(1)', false), -- ChangeTypeCode
('pro_order', 30, 3, 'The order in which the records were processed in to create the data supply.', 'integer(16)', false),
('uprn', 30, 4, 'Unique Property Reference Number.', 'integer(12)', false),
('succ_key', 30, 5, 'Key value to uniquely identify the successor cross reference record and the primary key for this table.', 'char(14)', false),
('start_date', 30, 6, 'Date on which the record was first loaded into the database.', 'date', false),
('end_date', 30, 7, 'The date on which the record ceased to exist.', 'date', true),
('last_update_date', 30, 8, 'The date on which any attribute on this record was last changed.', 'date', false),
('entry_date', 30, 9, 'The date on which the UPRN attached to this record was entered into the Local Authority database.', 'date', false),
('successor', 30, 10, 'UPRN of successor BLPU.', 'integer(12)', false),

('record_identifier', 31, 1, 'Identifies this as an Organisation Record (type 31).', 'integer(2)', false),
('change_type', 31, 2, 'Type of record change.', 'char(1)', false), -- ChangeTypeCode
('pro_order', 31, 3, 'The order in which the records were processed in to create the data supply.', 'integer(16)', false),
('uprn', 31, 4, 'Unique Property Reference Number (UPRN) - foreign key used to reference the organisation record to the corresponding BLPU.', 'integer(12)', false),
('org_key', 31, 5, 'Unique key for the organisation record and primary key for this table.', 'char(14)', false),
('organisation', 31, 6, 'Name of the organisation currently occupying the address record as provided by the local authority custodian.', 'text', false),
('legal_name', 31, 7, 'Registered legal name of the organisation.', 'text', true),
('start_date', 31, 8, 'The date on which this record was first loaded into the database.', 'date', false),
('end_date', 31, 9, 'The date on which this record ceased to exist.', 'date', true),
('last_update_date', 31, 10, 'The date on which an attribute on this record was last changed.', 'date', true),
('entry_date', 31, 11, 'The date on which the UPRN linked to this record was entered into the Local Authority database.', 'date', true),

('record_identifier', 32, 1, 'Identifies this as an Organisation Record (type 32).', 'integer(2)', false),
('change_type', 32, 2, 'Type of record change.', 'char(1)', false), -- ChangeTypeCode
('pro_order', 32, 3, 'The order in which the records were processed in to create the data supply.', 'integer(16)', false),
('uprn', 32, 4, 'Unique Property Reference Number (UPRN) - foreign key used to reference the organisation record to the corresponding BLPU.', 'integer(12)', false),
('class_key', 32, 5, 'Unique key for the classification record and primary key for this table.', 'char(14)', false),
('classification_code', 32, 6, 'A code that describes the classification of the record.', 'char(6)', false),
('class_scheme', 32, 7, 'The name of the classification scheme used for this record.', 'text', false),
('scheme_version', 32, 8, 'The classification scheme number.', 'numeric', false),
('start_date', 32, 9, 'Date that this classification record was first loaded into the database.', 'date', false),
('end_date', 32, 10, 'Date this classification record ceased to exist.', 'date', true),
('last_update_date', 32, 11, 'The date on which an attribute on this record was last changed.', 'date', false),
('entry_date', 32, 12, 'The date on which the address record associated with this classification record was inserted into the Local Authority database.', 'date', false),

('record_identifier', 99, 1, 'Identifies this as an Organisation Record (type 99).', 'integer(2)', false),
('next_volume_name', 99, 2, 'The sequential number of the next volume in the transfer set. For geographic supply this will always be zero (0). For non-geographic supply zero (0) will denote the last file in the transfer set.', 'integer(16)', false),
('record_count', 99, 3, 'Count of the number of records in the volume (excluding the header record, metadata and trailer records).', 'integer(16)', false),
('entry_date', 99, 4, 'The date of data entry.', 'date', false),
('time_stamp', 99, 5, 'Time of creation in HH:MM:SS.', 'time', false);


CREATE TABLE IF NOT EXISTS source (
  id char(6) PRIMARY KEY NOT NULL,
  description text
);

INSERT OR REPLACE INTO source (id, description) VALUES
('7666MT', 'OS MasterMap Topography Layer TOID'),
('7666MA', 'OS MasterMap Address Layer 2 TOID'),
('7666MI', 'OS MasterMap Integrated Transport Network TOID'),
('7666VC', 'Centrally created Council Tax'),
('7666VN', 'Centrally created non domestic rates'),
('7666OW', 'ONS Ward Code'),
('7666OP', 'ONS Parish Code');

CREATE TABLE IF NOT EXISTS language (
  id char(3) PRIMARY KEY NOT NULL,
  description text
);

INSERT OR REPLACE INTO language (id, description) VALUES
('ENG', 'English'),
('CYM', 'Welsh'),
('GAE', 'Gaelic (Scottish)'),
('BIL', 'Bilingual');

CREATE TABLE IF NOT EXISTS addressbase_postal (
  id char(1) PRIMARY KEY NOT NULL,
  description text
);

INSERT OR REPLACE INTO addressbase_postal (id, description) VALUES
('D', 'A record which is linked to PAF'),
('N', 'Not a postal address'),
('C', 'A record which is postal and has a parent record which is linked to PAF'),
('L', 'A record which is identified as postal based on Local Authority information');

CREATE TABLE IF NOT EXISTS country (
  id char(1) PRIMARY KEY NOT NULL,
  description text
);

INSERT OR REPLACE INTO country (id, description) VALUES
('E', 'This record is within England'),
('W', 'This record is within Wales'),
('S', 'This record is within Scotland'),
('N', 'This record is within Northern Ireland'),
('L', 'This record is within the Channel Islands'),
('M', 'This record is within the Isle of Man'),
('J', 'This record is not assigned to a country as it falls outside of the land boundaries used.');

CREATE TABLE IF NOT EXISTS blpu_state (
  id char(1) PRIMARY KEY NOT NULL,
  description text
);

INSERT OR REPLACE INTO blpu_state (id, description) VALUES
('1', 'under construction'),
('2', 'In use'),
('3', 'Unoccupied / vacant / derelict'),
('4', 'Demolished'),
('6', 'Planning permission granted');


CREATE TABLE IF NOT EXISTS rpc (
  id char(1) PRIMARY KEY NOT NULL,
  description text,
  notes text
);

INSERT OR REPLACE INTO rpc (id, description, notes) VALUES
('1', 'Central Internal Position', 'The address seed is contained within an OS MasterMap Topography Layer building and within 2.5m of its calculated centre. Or The seed is in the best possible position based on the nature of the premises e.g. Development Land, House Boat, Wind Farm.'),
('2', 'General Internal Position.', 'The address seed is contained within an OS MasterMap Topography Layer building but is more than 2.5m away from its calculated centre. Or The seed is in an internal position based on the nature of the premises e.g. Development Land, House Boat.'),
('3', 'Transitional Position.', 'The address seed has been changed from provisional to live in the last six months. It has been captured to a high level of positional accuracy, but the OS MasterMap Topography Layer feature is not yet captured. Please note the address seed will only be moved pending any imminent mapping updates.'),
('4', 'Street Location.', 'The address seed is plotted in accordance with the declared street start or end coordinates. Please note this is the highest accuracy possible for Street Records.'),
('5', 'Postcode Unit Position.', 'The address seed has been captured to Postcode Unit level. It will be updated when more information becomes available.'),
('9', 'Low accuracy - marked for priority review.', 'This address seed has been captured to a lower level of accuracy and will be updated as a priority over the coming releases.');

CREATE TABLE IF NOT EXISTS postcode_type (
  id char(1) PRIMARY KEY NOT NULL,
  description text
);

INSERT OR REPLACE INTO postcode_type (id, description) VALUES
('S', 'A small user, e.g. a residential property'),
('L', 'A large user, e.g. a large commercial company');

CREATE TABLE IF NOT EXISTS official_flag (
  id char(1) PRIMARY KEY NOT NULL,
  description text
);

INSERT OR REPLACE INTO official_flag (id, description) VALUES
('N', 'Unofficial Address'),
('Y', 'Official Address');

CREATE TABLE IF NOT EXISTS change_type (
  id char(1) PRIMARY KEY NOT NULL,
  description text
);

INSERT OR REPLACE INTO change_type (id, description) VALUES
('I', 'Insert'),
('U', 'Update'),
('D', 'Delete');

CREATE TABLE IF NOT EXISTS usrn_match_indicator (
  id char(1) PRIMARY KEY NOT NULL,
  description text
);

INSERT OR REPLACE INTO usrn_match_indicator (id, description) VALUES
('1', 'Matched manually to the nearest accessible Street.'),
('2', 'Matched spatially to the nearest USRN. Not necessarily the access street.');

CREATE TABLE IF NOT EXISTS street_record_type (
  id char(1) PRIMARY KEY NOT NULL,
  description text
);

INSERT OR REPLACE INTO street_record_type (id, description) VALUES
('1', 'Official designated Street Name'),
('2', 'Street Description'),
('3', 'Numbered Street'),
('4', 'Unofficial Street Description'),
('9', 'Description used for LLPG Access');

CREATE TABLE IF NOT EXISTS street_state (
  id char(1) PRIMARY KEY NOT NULL,
  description text
);

INSERT OR REPLACE INTO street_state (id, description) VALUES
('1', 'Under construction'),
('2', 'Open'),
('4', 'Permanently closed (STREET_END_DATE must be entered)');

CREATE TABLE IF NOT EXISTS street_surface (
  id char(1) PRIMARY KEY NOT NULL,
  description text
);

INSERT OR REPLACE INTO street_surface (id, description) VALUES
('1', 'Metalled'),
('2', 'UnMetalled'),
('3', 'Mixed');

CREATE TABLE IF NOT EXISTS file_type (
  id char(1) PRIMARY KEY NOT NULL,
  description text
);

INSERT OR REPLACE INTO file_type (id, description) VALUES
('F', 'Signifies the supply is a full supply'),
('C', 'Signifies the supply is a COU file');

CREATE TABLE IF NOT EXISTS street_classification (
  id char(1) PRIMARY KEY NOT NULL,
  description text
);

INSERT OR REPLACE INTO street_classification (id, description) VALUES
('4', 'Pedestrian way or footpath'),
('6', 'Cycletrack or cycleway'),
('8', 'All vehicles'),
('9', 'Restricted byway'),
('10', 'Bridleway');

CREATE TABLE IF NOT EXISTS logical_status (
  id char(1) PRIMARY KEY NOT NULL,
  description text
);

INSERT OR REPLACE INTO logical_status (id, description) VALUES
('1', 'Approved'),
('3', 'Alternative'),
('6', 'Provisional'),
('8', 'Historical');


-- 10
CREATE TABLE IF NOT EXISTS header (
  record_id            integer(2) NOT NULL,
  custodian_name       text       NOT NULL,
  local_custodian_code integer(4) NOT NULL,
  process_date         date       NOT NULL,
  volume_number        integer(3) NOT NULL,
  entry_date           date       NOT NULL,
  time_stamp           time       NOT NULL,
  version              char(7)    NOT NULL,
  file_type            char(1)    NOT NULL,

  FOREIGN KEY (file_type) REFERENCES file_type(id)
);

-- 11
CREATE TABLE IF NOT EXISTS street (
  record_id             integer(2)   NOT NULL,
  change_type           char(1)      NOT NULL,
  pro_order             integer(16)  NOT NULL,
  usrn                  integer(8)   PRIMARY KEY NOT NULL,
  record_type           char(1)      NOT NULL,
  swa_org_ref_naming    integer(4)   NOT NULL,
  state                 char(1),
  state_date            date,
  street_surface        char(1),
  street_classification char(1),
  version               integer(3)   NOT NULL,
  street_start_date     date         NOT NULL,
  street_end_date       date,
  last_update_date      date         NOT NULL,
  record_entry_date     date         NOT NULL,
  street_start_x        numeric(8,2) NOT NULL,
  street_start_y        numeric(9,2) NOT NULL,
  street_start_lat      numeric(8,7) NOT NULL,
  street_start_long     numeric(9,7) NOT NULL,
  street_end_x          numeric(8,2) NOT NULL,
  street_end_y          numeric(9,2) NOT NULL,
  street_end_lat        numeric(9,7) NOT NULL,
  street_end_long       numeric(8,7) NOT NULL,
  street_tolerance      integer(3)   NOT NULL,

  FOREIGN KEY (change_type)    REFERENCES change_type(id),
  FOREIGN KEY (record_type)    REFERENCES street_record_type(id),
  FOREIGN KEY (state)          REFERENCES street_state(id),
  FOREIGN KEY (street_surface) REFERENCES street_surface(id)
);

-- 15
CREATE TABLE IF NOT EXISTS street_descriptor (
  record_identifier   integer(2)  NOT NULL,
  change_type         char(1)     NOT NULL,
  pro_order           integer(16) NOT NULL,
  usrn                integer(8)  NOT NULL,
  street_description  text        NOT NULL,
  locality            text,
  town_name           text,
  administrative_area text        NOT NULL,
  language            char(3)     NOT NULL,
  start_date          date        NOT NULL,
  end_date            date,
  last_update_date    date        NOT NULL,
  entry_date          date        NOT NULL,

  FOREIGN KEY (change_type) REFERENCES change_type(id),
  /* FOREIGN KEY (usrn)        REFERENCES street(usrn), */
  FOREIGN KEY (language)    REFERENCES language(id)
);

-- 21
CREATE TABLE IF NOT EXISTS basic_land_property_unit (
  record_identifier    integer(2)   NOT NULL,
  change_type          char(1)      NOT NULL,
  pro_order            integer(16)  NOT NULL,
  uprn                 integer(12)  PRIMARY KEY NOT NULL,
  logical_status       char(1)      NOT NULL,
  blpu_state           char(1),
  blpu_state_date      date,
  parent_uprn          integer(12),
  x_coordinate         numeric(8,2) NOT NULL,
  y_coordinate         numeric(9,2) NOT NULL,
  latitude             numeric(9,7) NOT NULL,
  longitude            numeric(8,7) NOT NULL,
  rpc                  char(1)      NOT NULL,
  local_custodian_code integer(4)   NOT NULL,
  country              char(1)      NOT NULL,
  start_date           date         NOT NULL,
  end_date             date,
  last_update_date     date         NOT NULL,
  entry_date           date         NOT NULL,
  addressbase_postal   char(1)      NOT NULL,
  postal_code_locator  char(8)      NOT NULL,
  multi_occ_count      integer(4)   NOT NULL,

  FOREIGN KEY (change_type) REFERENCES change_type(id),
  FOREIGN KEY (logical_status) REFERENCES logical_status(id),
  FOREIGN KEY (blpu_state) REFERENCES blpu_state(id),
  FOREIGN KEY (rpc) REFERENCES rpc(id),
  FOREIGN KEY (country) REFERENCES country(id),
  FOREIGN KEY (addressbase_postal) REFERENCES addressbase_postal(id)
);

-- 23
CREATE TABLE IF NOT EXISTS application_cross_reference (
  record_identifier integer(2)  NOT NULL,
  change_type       char(1)     NOT NULL,
  pro_order         integer(16) NOT NULL,
  uprn              integer(12) NOT NULL,
  xref_key          char(14)    PRIMARY KEY NOT NULL,
  cross_reference   text        NOT NULL,
  version           integer(3),
  source            char(6)     NOT NULL,
  start_date        date        NOT NULL,
  end_date          date,
  last_update_date  date        NOT NULL,
  entry_date        date        NOT NULL,

  FOREIGN KEY (change_type) REFERENCES change_type(id),
  FOREIGN KEY (uprn)        REFERENCES basic_land_property_unit(uprn),
  FOREIGN KEY (source)      REFERENCES source(id)
);

-- 24
CREATE TABLE IF NOT EXISTS local_property_identifier (
  record_identifier    integer(2)  NOT NULL,
  change_type          char(1)     NOT NULL,
  pro_order            integer(16) NOT NULL,
  uprn                 integer(12) NOT NULL,
  lpi_key              char(14)    PRIMARY KEY NOT NULL,
  language             char(3)     NOT NULL,
  logical_status       char(1)     NOT NULL,
  start_date           date        NOT NULL,
  end_date             date,
  last_update_date     date        NOT NULL,
  entry_date           date        NOT NULL,
  sao_start_number     integer(4),
  sao_start_suffix     char(2),
  sao_end_number       integer(4),
  sao_end_suffix       char(2),
  sao_text             text,
  pao_start_number     integer(4),
  pao_start_suffix     char(2),
  pao_end_number       integer(4),
  pao_end_suffix       char(2),
  pao_text             text,
  usrn                 integer(8)  NOT NULL,
  usrn_match_indicator char(1)     NOT NULL,
  area_name            text,
  level                text,
  official_flag        char(1),


  FOREIGN KEY (change_type)          REFERENCES change_type(id),
  FOREIGN KEY (uprn)                 REFERENCES basic_land_property_unit(uprn),
  FOREIGN KEY (language)             REFERENCES language(id),
  FOREIGN KEY (logical_status)       REFERENCES logical_status(id),
  FOREIGN KEY (usrn)                 REFERENCES street(usrn),
  FOREIGN KEY (usrn_match_indicator) REFERENCES usrn_match_indicator(id),
  FOREIGN KEY (official_flag)        REFERENCES official_flag(id)
);

-- 28
CREATE TABLE IF NOT EXISTS delivery_point_address (
  record_identifier               integer(2)  NOT NULL,
  change_type                     char(1)     NOT NULL,
  pro_order                       integer(16) NOT NULL,
  uprn                            integer(12) NOT NULL,
  udprn                           integer(8)  PRIMARY KEY NOT NULL,
  organisation_name               text,
  department_name                 text,
  sub_building_name               text,
  building_name                   text,
  building_number                 integer(4),
  dependent_thoroughfare          text,
  thoroughfare                    text,
  double_dependent_locality       text,
  dependent_locality              text,
  post_town                       text        NOT NULL,
  postcode                        text        NOT NULL,
  postcode_type                   char(1)     NOT NULL,
  delivery_point_suffix           char(2)     NOT NULL,
  welsh_dependent_thoroughfare    text,
  welsh_thoroughfare              text,
  welsh_double_dependent_locality text,
  welsh_dependent_locality        text,
  welsh_post_town                 text,
  po_box_number                   char(6),
  process_date                    date        NOT NULL,
  start_date                      date        NOT NULL,
  end_date                        date,
  last_update_date                date        NOT NULL,
  entry_date                      date        NOT NULL,

  FOREIGN KEY (change_type) REFERENCES change_type(id),
  FOREIGN KEY (uprn) REFERENCES basic_land_property_unit(uprn),
  FOREIGN KEY (postcode_type) REFERENCES postcode_type(id)
);

-- 29
CREATE TABLE IF NOT EXISTS metadata (
  record_identifier    integer(2)  NOT NULL,
  gaz_name             text        NOT NULL,
  gaz_scope            text        NOT NULL,
  ter_of_use           text        NOT NULL,
  linked_data          text        NOT NULL,
  gaz_owner            text        NOT NULL,
  ngaz_freq            char(1)     NOT NULL,
  custodian_name       text        NOT NULL,
  custodian_uprn       integer(12) NOT NULL,
  local_custodian_code integer(4)  NOT NULL,
  co_ord_system        text        NOT NULL,
  co_ord_unit          text        NOT NULL,
  meta_date            date        NOT NULL,
  class_scheme         text        NOT NULL,
  gaz_date             date        NOT NULL,
  language             char(3)     NOT NULL,
  character_set        text        NOT NULL,

  FOREIGN KEY (language) REFERENCES language(id)
);

-- 30
CREATE TABLE IF NOT EXISTS successor (
  record_identifier integer(2)  NOT NULL,
  change_type       char(1)     NOT NULL,
  pro_order         integer(16) NOT NULL,
  uprn              integer(12) NOT NULL,
  succ_key          char(14)    PRIMARY KEY NOT NULL,
  start_date        date        NOT NULL,
  end_date          date,
  last_update_date  date        NOT NULL,
  entry_date        date        NOT NULL,
  successor         integer(12) NOT NULL,

  FOREIGN KEY (change_type) REFERENCES change_type(id),
  FOREIGN KEY (uprn) REFERENCES basic_land_property_unit(uprn)
);

-- 31
CREATE TABLE IF NOT EXISTS organisation (
  record_identifier integer(2)  NOT NULL,
  change_type       char(1)     NOT NULL,
  pro_order         integer(16) NOT NULL,
  uprn              integer(12) NOT NULL,
  org_key           char(14)    PRIMARY KEY NOT NULL,
  organisation      text        NOT NULL,
  legal_name        text,
  start_date        date        NOT NULL,
  end_date          date,
  last_update_date  date        NOT NULL,
  entry_date        date        NOT NULL,

  FOREIGN KEY (change_type) REFERENCES change_type(id),
  FOREIGN KEY (uprn) REFERENCES basic_land_property_unit(uprn)
);

-- 32
CREATE TABLE IF NOT EXISTS classification (
  record_identifier   integer(2)  NOT NULL,
  change_type         char(1)     NOT NULL,
  pro_order           integer(16) NOT NULL,
  uprn                integer(12) NOT NULL,
  class_key           char(14)    PRIMARY KEY NOT NULL,
  classification_code char(6)     NOT NULL,
  class_scheme        text        NOT NULL,
  scheme_version      numeric     NOT NULL,
  start_date          date        NOT NULL,
  end_date            date,
  last_update_date    date        NOT NULL,
  entry_date          date        NOT NULL,

  FOREIGN KEY (change_type) REFERENCES change_type(id),
  FOREIGN KEY (uprn) REFERENCES basic_land_property_unit(uprn)
);

-- 99
CREATE TABLE IF NOT EXISTS trailer (
  record_identifier integer(2) NOT NULL,
  next_volume_name integer(16) NOT NULL,
  record_count integer(16) NOT NULL,
  entry_date date NOT NULL,
  time_stamp date NOT NULL
);
