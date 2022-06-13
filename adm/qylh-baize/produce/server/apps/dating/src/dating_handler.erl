%% @author rong
%% @doc
-module(dating_handler).

-include("table.hrl").
-include("proto.hrl").
-include("game.hrl").
-include("role.hrl").
-include("errno.hrl").
-include("enum.hrl").
-include("faker.hrl").

-export([handle/3]).

handle(?DATING_HALL, Tos, RoleSt) ->
    #m_dating_hall_tos{page=Page} = Tos,
    #role_info{gender=Gender} = role_data:get(?DB_ROLE_INFO),
    {ok, Mine, List} = dating_manager:paginate(RoleSt#role_st.role, Gender, Page),
    ?ucast(#m_dating_hall_toc{mine=Mine, page=Page, list=List});

handle(?DATING_TAG, Tos, RoleSt) ->
    #m_dating_tag_tos{tags=Tags} = Tos,
    ?_check(length(lists:usort(Tags)) == length(Tags), ?ERR_GAME_BAD_ARGS, [?DATING_TAG]),
    ?_check(lists:all(fun(ID) -> lists:member(ID, cfg_dating_tag:list()) end, Tags), 
        ?ERR_GAME_BAD_ARGS, [?DATING_TAG]),
    dating_manager:set_tags(RoleSt#role_st.role, Tags),
    ?ucast(#m_dating_tag_toc{tags=Tags});

handle(?DATING_FLIRT, Tos, RoleSt) ->
    #m_dating_flirt_tos{role_id=TargetID} = Tos,
    friend_handler:request(TargetID, RoleSt),
    ?ucast(#m_dating_flirt_toc{});

handle(?DATING_MATCH, _Tos, RoleSt) ->
    #role_info{gender=Gender} = role_data:get(?DB_ROLE_INFO),
    FakerID = case Gender of
        ?GENDER_MALE ->
            ut_rand:choose(cfg_faker:gender(?GENDER_FEMALE));
        ?GENDER_FEMALE ->
            ut_rand:choose(cfg_faker:gender(?GENDER_MALE))
    end,
    Base = role:get_base(FakerID),
    ?ucast(#m_dating_match_toc{role=role:get_base(FakerID)}),
    Content = ut_rand:choose(cfg_faker_chat:content(Base#p_role_base.gender)),
    chat_handler:faker_send_chat(FakerID, RoleSt#role_st.role, Content).

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
