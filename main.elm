module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Json.Decode as Decode


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


type alias Model =
    { name : String
    , url : String
    , loading : Bool
    , breeds : List String
    , selectedBreed : String
    }


type alias Breeds =
    List String


modelInitialValue : Model
modelInitialValue =
    { name = "Test"
    , url = "qweqwe"
    , loading = False
    , breeds = []
    , selectedBreed = "test"
    }


type Msg
    = NewImage (Result Http.Error String)
    | LoadImage String
    | LoadBreedList
    | ReceiveBreedList (Result Http.Error Breeds)
    | BreedSelected String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NewImage (Ok newUrl) ->
            ( { model | url = newUrl, loading = False }, Cmd.none )

        NewImage (Err _) ->
            ( { model | loading = False }, Cmd.none )

        LoadImage topic ->
            ( { model | url = "./assets/loading.gif", loading = True }, getRandomGif topic model )

        LoadBreedList ->
            ( model, getBreedList )

        ReceiveBreedList (Ok breeds) ->
            ( { model | breeds = breeds }, Cmd.none )

        ReceiveBreedList (Err _) ->
            ( { model | loading = False }, Cmd.none )

        BreedSelected breed ->
            ( { model | selectedBreed = breed }, Cmd.none )


onChange : (String -> msg) -> Html.Attribute msg
onChange tagger =
    on "change" (Decode.map tagger Html.Events.targetValue)


view : Model -> Html Msg
view model =
    div []
        [ div [ style [ ( "margin", "20px auto" ), ( "text-align", "center" ) ] ]
            [ if List.isEmpty model.breeds then
                ul [] []
              else
                select [ style selectStyle, onChange BreedSelected ] (List.map (\x -> option [] [ text x ]) model.breeds)
            , button
                [ style
                    [ ( "width", "150px" )
                    , ( "height", "40px" )
                    , ( "border-radius", "5px" )
                    , ( "border", "solid 1px #999" )
                    , ( "outline", "none" )
                    ]
                , onClick (LoadImage "puppy")
                ]
                [ text "Load Picture" ]
            ]
        , div [ style [ ( "margin", "auto 0" ), ( "text-align", "center" ), ( "min-width", "100px" ), ( "min-height", "100px" ) ] ]
            [ if model.loading then
                img [ src model.url, width 100, height 100 ] []
              else
                img [ src model.url ] []
            ]
        ]


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


init : ( Model, Cmd Msg )
init =
    ( modelInitialValue, getBreedList )



-- HTTP


getRandomGif : String -> Model -> Cmd Msg
getRandomGif topic model =
    let
        url =
            "https://dog.ceo/api/breed/" ++ model.selectedBreed ++ "/images/random"
    in
        Http.send NewImage (Http.get url decodeGifUrl)


decodeGifUrl : Decode.Decoder String
decodeGifUrl =
    Decode.at [ "message" ] Decode.string


getBreedList : Cmd Msg
getBreedList =
    let
        url =
            "https://dog.ceo/api/breeds/list"
    in
        Http.send ReceiveBreedList (Http.get url decodeBreedList)


decodeBreedList : Decode.Decoder (List String)
decodeBreedList =
    Decode.at [ "message" ] (Decode.list Decode.string)



{-
   https://github.com/toddmotto/public-apis
-}


selectStyle : List ( String, String )
selectStyle =
    [ ( "display", "block" )
    , ( "margin", "20px auto" )
    , ( "width", "150px" )
    , ( "height", "35px" )
    , ( "text-align", "center" )
    ]
