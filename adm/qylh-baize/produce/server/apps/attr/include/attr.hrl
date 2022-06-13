-ifndef(ATTR_HRL).
-define(ATTR_HRL, ok).

-define(_attr(Attr, Code), maps:get(Code, Attr, 0)).
-define(_attr(Attr, Code, Default), maps:get(Code, Attr, Default)).

-define(_attrper(Attr, Code), ?_per(?_attr(Attr, Code))).
-define(_attrper(Attr, Code, Default), ?_per(?_attr(Attr, Code, Default))).

-define(_setattr(Attr, Code, Val), maps:put(Code, Val, Attr)).

-endif.