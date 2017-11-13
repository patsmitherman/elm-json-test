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
    }


modelInitialValue : Model
modelInitialValue =
    { name = "Test"
    , url = "qweqwe"
    , loading = False
    }


type Msg
    = NewImage (Result Http.Error String)
    | LoadImage String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NewImage (Ok newUrl) ->
            ( { model | url = newUrl, loading = False }, Cmd.none )

        NewImage (Err _) ->
            ( { model | loading = False }, Cmd.none )

        LoadImage topic ->
            ( { model | url = "./assets/loading.gif", loading = True }, getRandomGif topic )


view : Model -> Html Msg
view model =
    div []
        [ div [ style [ ( "margin", "20px auto" ), ( "text-align", "center" ) ] ]
            [ button
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
    ( modelInitialValue, Cmd.none )



-- HTTP


getRandomGif : String -> Cmd Msg
getRandomGif topic =
    let
        url =
            "https://dog.ceo/api/breed/boxer/images/random"

        --"https://api.giphy.com/v1/gifs/random?api_key=dc6zaTOxFJmzC&tag=" ++ topic
    in
        Http.send NewImage (Http.get url decodeGifUrl)


decodeGifUrl : Decode.Decoder String
decodeGifUrl =
    Decode.at [ "message" ] Decode.string



--Decode.at [ "data", "image_url" ] Decode.string
{- {
       status: "success",
       message: "https://dog.ceo/api/img/vizsla/n02100583_2265.jpg"
   }
-}
{-
   https://github.com/toddmotto/public-apis
-}
