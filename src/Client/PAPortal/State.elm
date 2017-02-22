module Client.PAPortal.State exposing (..)

import Client.PAPortal.Types exposing (..)
import Client.PAPortal.Pages.SkinManager as Skin
import Ports exposing (..)

import Date exposing (Date)
import Task exposing (perform, succeed)

initModel: String -> Maybe Date -> Maybe SelectedDate -> (Model, Cmd Msg)
initModel userId currentDate selectedDate =
  let
    user =
      {id=userId
      , firstName="Jeff"
      , lastName="PaGuy"
      , avatarSrc=Just "https://files.graph.cool/ciykpioqm1wl00120k2e8s4la/ciyvfw6ab423z01890up60nza"
      }
  in
    (
    { user = user
    , extras = Loading
    , currentDate = currentDate
    , selectedDate =
        case selectedDate of
          Just date -> date
          Nothing -> currentDate
    , currentView = LiveMonitor
    , skinModel = Skin.initModel
    }
    , Task.perform (always LoadRemoteData) (Task.succeed ())
    )

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ChangeView view ->
            ( { model | currentView = view }, Cmd.none )
        LoadRemoteData ->
          (model, getAllExtraInfo("2014"))
        SetSelectedDate newDate ->
          initModel model.user.id (model.currentDate) (Just (Just newDate))
        Profiles profs ->
          ({model | extras = Success (Just profs)}, Cmd.none)
        SkinMsg subMsg ->
            let
                ( updatedSkinModel, skinCmd ) =
                    Skin.update subMsg model.skinModel
            in
                ( { model | skinModel = updatedSkinModel }
                , Cmd.none
                )

subscriptions : Model -> Sub Msg
subscriptions model =
    receiveAllExtraInfo Profiles
