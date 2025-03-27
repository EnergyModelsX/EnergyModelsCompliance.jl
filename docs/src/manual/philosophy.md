# [Philosophy](@id man-phil)

The aim of the `EnergyModelsX` framework is to provide the user with an extensible energy system optimization framework in which the user can add new technology descriptions without changes to the core structure of the framework.
Introducing new technology descriptions is for example explained in *[how to create a new element](@extref EnergyModelsBase how_to-create_element)* and *[how to create a new node](@extref EnergyModelsBase how_to-create_node)*.
However, these new elements must satisfy certain criteria to work seamless wihin `EnergyModelsX`.

`EnergyModelsCompliance` provides the user with compatibility checks for new developed subtypes of [`Node`](@extref EnergyModelsBase lib-pub-nodes)s and [`Link`](@extref EnergyModelsBase lib-pub-links)s, both introduced in `EnergyModelsBase`, and  [`Area`](@extref EnergyModelsGeography lib-pub-area)s and  [`TransmissionMode`](@extref EnergyModelsGeography lib-pub-mode)s, both introduced in `EnergyModelsGeography`.
These functions, explained in *[How to use the package](@ref man-use)*, can be utilized for identifying potential problems when incorporating new subtypes for the elements outlined above.
