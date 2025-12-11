variable "location"   { type = string }
variable "rg_name"    { type = string }
variable "subnet_id"  { type = string } # subnet for Application Gateway
variable "appgw_name" { type = string }
variable "pip_name"   { type = string }
variable "tags"       { type = map(string) }
